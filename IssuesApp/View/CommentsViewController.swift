//
//  CommentsViewController.swift
//  IssuesApp
//
//  Created by 강태훈 on 2018. 4. 28..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

class CommentsViewController: UIViewController, ViewControllerFromStoryBoard, LoadMoreViewControllerType {
    
    @IBOutlet weak  var collectionView: UICollectionView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    var disposeBag: DisposeBag = DisposeBag()
    var estimateCell: CommentCell = CommentCell.cellFromNib
    var datasourceOut: BehaviorRelay<[Model.Comment]> = BehaviorRelay(value: [])
    var datasourceIn: PublishSubject<((String, String, Int)) -> Observable<[Model.Comment]>> = PublishSubject()
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var nextPageID: BehaviorRelay<Int> = BehaviorRelay(value: 1)
    var canLoadMore: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var loadMoreCell: LoadMoreCell?
    
    var owner: String = ""
    var repo: String = ""
    var issue: Model.Issue! {
        didSet{
            guard let header = collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? CommentHeaderCell else { return }
            header.update(data: issue)
        }
    }
    
    var headerSize: CGSize = CGSize.zero
    
    typealias Cell = CommentCell
    typealias APIParameter = (String, String, Int)
    var stateButtonTappedSubject = PublishSubject<Void>()
    var parentViewReload: PublishSubject<Model.Issue>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "CommentCell", bundle: nil), forCellWithReuseIdentifier: "CommentCell")
        collectionView.refreshControl = refreshControl
        self.title = "#\(issue.number)"
        bind()
    }
    
    static func viewController(owner: String, repo: String, issue: Model.Issue) -> CommentsViewController {
        let viewController = CommentsViewController.viewController
        viewController.owner = owner
        viewController.repo = repo
        viewController.issue = issue
        return viewController
    }
    
    func apiCall(api: ((String, String, Int)) -> Observable<[Model.Comment]>) -> Observable<[Model.Comment]> {
        return api((owner, repo, issue.number))
    }
    
    func headerView(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CommentHeaderCell", for: indexPath) as? CommentHeaderCell
        header?.stateButtonTappedSubject = stateButtonTappedSubject
        header?.update(data: issue)
        return header
    }
}

extension CommentsViewController {
    func bind() {
        datasourceInBind()
        nextPageIDBind(api: App.api.issueComments)
        datasourceOutBindtoCollectionView()
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        register(refreshControl: refreshControl)
        registerLoadMore(collectionView: collectionView)
        
        canLoadMore.subscribe(onNext: { [weak self] can in
            self?.loadMoreCell?.load(can)
        }).disposed(by: disposeBag)
        
        stateButtonTappedSubject.flatMapFirst { [weak self] _ -> Observable<Model.Issue> in
            guard let `self` =  self else {return Observable.empty()}
            let isStateOpen = self.issue.state == Model.Issue.State.open
            let nextState: Model.Issue.State = isStateOpen ? .closed : .open
            let toggledIssue = self.issue.update(state: nextState)
            return App.api.editIssue(owner: self.owner, repo: self.repo, issue: toggledIssue)
            .retry(2)
            }.subscribe(onNext: { [weak self] issue in
                self?.issue = issue
                self?.parentViewReload?.onNext(issue)
        }).disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
            guard let `self` = self else {return}
            let actualKeyboardHeight = keyboardVisibleHeight - self.view.safeAreaInsets.bottom
            self.inputViewBottomConstraint.constant = actualKeyboardHeight
                
            self.view.setNeedsLayout()
            UIView.animate(withDuration: 0, animations: {
                self.collectionView.contentInset.bottom = actualKeyboardHeight + 46
                self.collectionView.scrollIndicatorInsets.bottom = actualKeyboardHeight + 46
                self.view.layoutIfNeeded()
            })
        }).disposed(by: disposeBag)
        
        RxKeyboard.instance.willShowVisibleHeight.map { [weak self] keyboardVisibleHeight -> CGFloat in
            guard let collectionView = self?.collectionView else { return 0 }
            let remainContentsHeight = collectionView.frame.height - 64 - keyboardVisibleHeight - 46
            if collectionView.contentOffset.y + remainContentsHeight + keyboardVisibleHeight <= collectionView.contentSize.height {
                return keyboardVisibleHeight
            }else{
                return collectionView.contentSize.height - remainContentsHeight
            }
            }.filter{ $0 > 0 }
            .drive(onNext: { [weak self] differ in
                self?.collectionView.contentOffset.y += differ
        }).disposed(by: disposeBag)
        
        
        sendButton.rx.tap.asObservable().withLatestFrom(commentTextField.rx.text.orEmpty)
            .filter { !$0.isEmpty } //텍스트가 없는경우 거름
            .flatMapFirst { [weak self] comment -> Observable<Model.Comment> in
                guard let `self` = self else { return Observable.empty() }
                return App.api.postComment(owner: self.owner, repo: self.repo, number: self.issue.number, comment: comment)
            .retry()
            }.do(onNext: { [weak self] _ in
                self?.commentTextField.text = ""
                self?.commentTextField.resignFirstResponder()
            })
            
            .subscribe(onNext: { [weak self] comment in
                guard let `self` = self else { return }
                var datasource = self.datasourceOut.value
                datasource.append(comment)
                self.datasourceOut.accept(datasource)
                
                let newCommentCount = self.issue.comments + 1
                let newIssue = self.issue.update(commentsCount: newCommentCount)
                self.issue = newIssue
                self.parentViewReload?.onNext(newIssue)
            }).disposed(by: disposeBag)
        
        
        
        
        
    }
}

extension CommentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItem(indexPath: indexPath, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if headerSize == CGSize.zero {
            headerSize = CommentHeaderCell.headerSize(issue: issue, width: collectionView.frame.width)
        }
        return headerSize
    }
}
