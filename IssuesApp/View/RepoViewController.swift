//
//  RepoViewController.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 5..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepoViewController: UIViewController {
  @IBOutlet weak var logoutButton: UIBarButtonItem!
  @IBOutlet weak var historyButton: UIBarButtonItem!
  @IBOutlet weak var enterButton: UIButton!
  @IBOutlet weak var ownerTextField: UITextField!
  @IBOutlet weak var repoTextfield: UITextField!
  
  var disposeBag: DisposeBag = DisposeBag()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lastRepo = App.preferenceManager.lastRepo{
            
            //rx텍스트에 넣는 이유는 combineLatest 시켰기 때문에.
            ownerTextField.rx.text.onNext(lastRepo.owner)
            ownerTextField.sendActions(for: .valueChanged) //바뀐값으로 변경
            repoTextfield.rx.text.onNext(lastRepo.repo)
            repoTextfield.sendActions(for: .valueChanged)
        }
    }
}

extension RepoViewController {
    func bind() {
        
        logoutButton.rx.tap.subscribe(onNext: { _ in
            App.preferenceManager.token = nil
        }).disposed(by: disposeBag)

        let textTupleObservable: Observable<(String, String)> = Observable.combineLatest(ownerTextField.rx.text.orEmpty, repoTextfield.rx.text.orEmpty) {
            (owner, repo) -> (String, String) in
            return (owner, repo)
        }
        
        let enterButtonObservable: Observable<(String, String)> = enterButton.rx.tap.withLatestFrom(textTupleObservable).share()
        
        enterButtonObservable.filter { (owner, _) -> Bool in
            owner.isEmpty
            }.flatMap { [weak self] (_) -> Observable<Void> in
                App.showAlert(title: "Owner를 입력하지 않았습니다.",
                              message: "Owner를 입력해주세요.",
                              buttonTitle: "확인",
                              onView: self)
        }.subscribe().disposed(by: disposeBag)
        
        enterButtonObservable.filter { (owner, repo) -> Bool in
            !owner.isEmpty && repo.isEmpty
            }.flatMap { [weak self] (_) -> Observable<Void> in
                App.showAlert(title: "repo를 입력하지 않았습니다.",
                              message: "repo를 입력해주세요.",
                              buttonTitle: "확인",
                              onView: self)
            }.subscribe().disposed(by: disposeBag)
        
        
        enterButtonObservable.filter{ (owner, repo) -> Bool in
            !owner.isEmpty && !repo.isEmpty
            }.subscribe(onNext: { [weak self] (owner, repo) in
                App.preferenceManager.addToHistory(owner: owner, repo: repo)
                App.preferenceManager.setLastRepo(owner: owner, repo: repo)
                let viewController = IssuesViewController.viewController(owner: owner, repo: repo)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }).disposed(by: disposeBag)
        
        historyButton.rx.tap.flatMap{ [weak self] _ in
            return HistoryViewController.rx.create(parent: self)
            }.subscribe(onNext: { [weak self]  (repo) in
                App.preferenceManager.setLastRepo(owner: repo.owner, repo: repo.repo)
                let viewController = IssuesViewController.viewController(owner: repo.owner, repo: repo.repo)
                self?.navigationController?.pushViewController(viewController, animated: true)
        }).disposed(by: disposeBag)
    
    }
}





















