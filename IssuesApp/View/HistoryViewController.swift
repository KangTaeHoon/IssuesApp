//
//  HistoryViewController.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 8..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController,
                             ViewControllerFromStoryBoard {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var closeButton: UIBarButtonItem!
  var disposeBag: DisposeBag = DisposeBag()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00)
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00)]
        bind()
    }
}

extension HistoryViewController {
    
    func bind() {
        Observable.just(App.preferenceManager.history.repos)
            .bind(to: tableView.rx.items(cellIdentifier: "RepoCell", cellType: UITableViewCell.self)) { (index, repo, cell) in
                cell.textLabel?.text = "/\(repo.owner)/\(repo.repo)"
        }.disposed(by: disposeBag)
    }
}

extension Reactive where Base: HistoryViewController {
    
    var selectedRepo: Observable<Repo> {
        return base.tableView.rx.itemSelected.map { indexPath -> Repo in
            return App.preferenceManager.history.repos[indexPath.row]
        }
    }
    
    fileprivate static func create(parent: UIViewController?, animated: Bool = true) -> Observable<HistoryViewController> {
        
        return Observable<HistoryViewController>.create{ (observer) -> Disposable in
            let viewController = HistoryViewController.viewController
            let dismissDisposable = viewController.closeButton.rx.tap.subscribe(onNext: { [weak viewController] _ in
                viewController?.dismiss(animated: animated, completion: nil)
            })
            
            parent?.present(viewController.wrapNavigationController, animated: animated, completion: { [weak viewController] in
                guard let viewController = viewController else {
                    observer.onError(RxCocoaError.unknown)
                    return}
                observer.onNext(viewController) //vc를 보내는 시점에 없을수가 있음. 그래서 [weak viewController]
            })
            return Disposables.create([dismissDisposable, Disposables.create{ viewController.dismiss(animated: animated, completion: nil)
            }])
        }
    }
    
    static func create(parent: UIViewController?, animated: Bool = true) -> Observable<Repo> {
        return self.create(parent: parent, animated: animated).flatMap{ (viewController: HistoryViewController) -> Observable<Repo> in
            viewController.rx.selectedRepo
        }.take(1)
    }
    
    
}














