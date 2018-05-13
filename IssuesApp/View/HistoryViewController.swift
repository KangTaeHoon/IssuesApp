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

class HistoryViewController: UIViewController, ModelViewControllerType {
    
    
    typealias ReturnType = Repo
    
    
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
    
    func returnObservable() -> Observable<Repo> {
        return tableView.rx.itemSelected.map { indexPath -> Repo in
            return App.preferenceManager.history.repos[indexPath.row]
        }
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















