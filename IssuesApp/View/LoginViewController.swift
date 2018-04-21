//
//  LoginViewController.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 8..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController,
    
ViewControllerFromStoryBoard {
    @IBOutlet weak var loginButton: UIButton!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension LoginViewController {
    
    func bind() {
        loginButton.rx.tap.flatMap { _ in
            return App.api.getToken()
            
            }.subscribe(onNext: { (token, refreshToken) in //성공시 토큰 저장.
                print("token: \(token)")
                App.preferenceManager.token = token
                App.preferenceManager.refreshToken = refreshToken
                
            }, onError: { [weak self] error in
                guard let `self` = self else { return }
                let alert = UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }).disposed(by: disposeBag)
        
        App.preferenceManager.rx.token.filter { $0 != nil } //로그인이되면 뷰컨을 내린다.
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    static func register(){
        
        //싱글톤이라 해제되지않는 애임. 디스포즈 안할거야.
        _ = App.preferenceManager.rx.token.filter{ $0 == nil } //토큰이 없음을 감지하면 present.
            .delay(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
            let viewController = LoginViewController.viewController
            App.delegate.window?.rootViewController?.present(viewController, animated: true, completion: nil)
        })
    }
    
    
    
    
    
    
    
    
    
    

}
