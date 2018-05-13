//
//  PostIssueViewController.swift
//  IssuesApp
//
//  Created by 강태훈 on 2018. 5. 12..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostIssueViewController: UIViewController, ModelViewControllerType {
    
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var doneButton: UIBarButtonItem!
    var disposeBag = DisposeBag()
    
    func returnObservable() -> Observable<(String, String)> {
        
        let texts: Observable<(String, String)> = Observable.combineLatest([titleTextField.rx.text.orEmpty, bodyTextView.rx.text.orEmpty]) {
            (strings) -> (String, String) in
            return (strings[0], strings[1])
        }
        return doneButton.rx.tap.asObservable().withLatestFrom(texts)
    }
    
    typealias ReturnType = (String, String)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00)
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00)]

    }

}

extension PostIssueViewController {
    func bind(){
        
    }
}
