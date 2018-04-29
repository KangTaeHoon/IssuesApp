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
    var disposeBag: DisposeBag = DisposeBag()
    var estimateCell: CommentCell = CommentCell.cellFromNib
    var datasourceOut: BehaviorRelay<[Model.Comment]> = BehaviorRelay(value: [])
    var datasourceIn: PublishSubject<((String, String, Int)) -> Observable<[Model.Comment]>> = PublishSubject()
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var nextPageID: BehaviorRelay<Int> = BehaviorRelay(value: 1)
    var canLoadMore: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var loadMoreCell: LoadMoreCell?
    
    var owner: String = ""
    var repo: String = ""
    var issue: Model.Issue!
    var headerSize: CGSize = CGSize.zero
    
    typealias Cell = CommentCell
    typealias APIParameter = (String, String, Int)
    
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
