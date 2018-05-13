//
//  IssuesViewController.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 9..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class IssuesViewController: UIViewController, ViewControllerFromStoryBoard, LoadMoreViewControllerType {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var owner: String = ""
    fileprivate var repo: String = ""
    var disposeBag: DisposeBag = DisposeBag()
    
    var estimateCell: IssueCell = IssueCell.cellFromNib
    var datasourceOut: BehaviorRelay<[Model.Issue]> = BehaviorRelay(value: []) //컬렉션뷰에 뿌리기 위한 값
    var datasourceIn: PublishSubject<((String, String)) -> Observable<[Model.Issue]>> = PublishSubject()
    var refreshControl = UIRefreshControl()
    var nextPageID: BehaviorRelay<Int> = BehaviorRelay(value: 1)
    var canLoadMore: BehaviorRelay<Bool> = BehaviorRelay(value: true) //처음에는 더 부를수 있는 상태여야하니까 트루
    var loadMoreCell: LoadMoreCell? //처음엔 없음
    var issueModifiedSubject: PublishSubject<Model.Issue> = PublishSubject()
    @IBOutlet weak var postIssueButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(owner)/\(repo)"
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil), forCellWithReuseIdentifier: "IssueCell")
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
        bind()
    }
  
    static func viewController(owner: String, repo: String) -> IssuesViewController {
        let viewController = IssuesViewController.viewController
        viewController.owner = owner
        viewController.repo = repo
        return viewController
    }
    
    func apiCall(api: ((String, String)) -> Observable<[Model.Issue]>) -> Observable<[Model.Issue]> {
        return api((owner, repo))
    }
    
    func headerView(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
    }
}



extension IssuesViewController {
    func bind() {

        datasourceInBind()
        nextPageIDBind(api: App.api.repoIssues)
        datasourceOutBindtoCollectionView()
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        register(refreshControl: refreshControl)
        registerLoadMore(collectionView: collectionView)
        
        canLoadMore.subscribe(onNext: { [weak self] can in
            self?.loadMoreCell?.load(can)
        }).disposed(by: disposeBag)
//        canLoadMore.bind(to: loadMoreCell.rx.load) 옵셔널인 경우는 이게안됨.
        
        issueModifiedSubject.withLatestFrom(datasourceOut) { ($0, $1) }
            .flatMap{ (issue, issues) -> Observable<[Model.Issue]> in
                guard let index: Int = issues.index(of: issue) else {return Observable.empty()}
                var issues = issues //변경할수 있는 어레이로 바꾼다
                issues[index] = issue
                return Observable.just(issues)
        }.bind(to: datasourceOut).disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            let issue = self.datasourceOut.value[indexPath.item]
            let viewController = CommentsViewController.viewController(owner: self.owner, repo: self.repo, issue: issue)
            viewController.parentViewReload = self.issueModifiedSubject
            self.navigationController?.pushViewController(viewController, animated: true)
        }).disposed(by: disposeBag)
        
        
        postIssueButton.rx.tap.flatMap { [weak self] _ -> Observable<(String, String)> in
            return PostIssueViewController.rx.create(parent: self)
            
            }.flatMapFirst { [weak self] strings -> Observable<(Model.Issue)> in
                guard let `self` = self else { return Observable.empty() }
                let (title, body) = strings
                return App.api.postIssue(owner: self.owner, repo: self.repo, title: title, body: body)
            .retry()
            }.subscribe(onNext: { [weak self] issue in
                guard let `self` = self else {return}
                var datasource = self.datasourceOut.value
                datasource.insert(issue, at: 0)
                self.datasourceOut.accept(datasource)
            }).disposed(by: disposeBag)
    }
}


extension IssuesViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItem(indexPath: indexPath, collectionView: collectionView)
    }
}










