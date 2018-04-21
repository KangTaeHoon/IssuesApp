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

final class IssuesViewController: UIViewController, ViewControllerFromStoryBoard {
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var owner: String = ""
    fileprivate var repo: String = ""
    fileprivate var disposeBag: DisposeBag = DisposeBag()
    var estimateCell: IssueCell = IssueCell.cellFromNib
    var datasourceOut: BehaviorRelay<[Model.Issue]> = BehaviorRelay(value: []) //컬렉션뷰에 뿌리기 위한 값
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(owner)/\(repo)"
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil), forCellWithReuseIdentifier: "IssueCell")
        bind()
    }
  
    static func viewController(owner: String, repo: String) -> IssuesViewController {
        let viewController = IssuesViewController.viewController
        viewController.owner = owner
        viewController.repo = repo
        return viewController
    }
}

extension IssuesViewController {
    func bind() {
        App.api.repoIssues(owner: owner, repo: repo).bind(to: datasourceOut).disposed(by: disposeBag)
            
        datasourceOut
            .bind(to: collectionView.rx.items(cellIdentifier: "IssueCell", cellType: IssueCell.self)) { (index, issue, cell) in
            cell.update(data: issue)
        }.disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension IssuesViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let issues = datasourceOut.value
        let issue = issues[indexPath.item]
        estimateCell.update(data: issue)
        let targetSize = CGSize(width: collectionView.frame.size.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize,
                                                                             withHorizontalFittingPriority: .required,
                                                                             verticalFittingPriority: .defaultLow) //모른다고함.. 그냥 쓰라함
        return estimatedSize
    }
}

extension IssuesViewController {

  func register(refreshControl: UIRefreshControl) {
    
   
  }
  
  func registerLoadMore(collectionView: UICollectionView) {
    
    
  }
}

