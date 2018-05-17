//
//  ErrorViewController.swift
//  IssuesApp
//
//  Created by 강태훈 on 2018. 5. 12..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ErrorViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind7()
        bind6()
        bind5()
        bind4()
        bind3()
        bind2()
        bind1()
    }
}

extension ErrorViewController {
    
    func bind1() { //정상적인 경우는?
        button.rx.tap.debug("button.rx.tap")
            .flatMap { _ in
                Observable.just(1).debug("Observable.just(1)")
        }.subscribe()
        .disposed(by: disposeBag)
    }

    func bind2() { //에러가 나는 경우는?
        button2.rx.tap.debug("button.rx.tap")
            .flatMap { _ in
                Observable<Int>.error(RxError.unknown).debug("Observable.error")
            }.subscribe()
            .disposed(by: disposeBag)
    }
    
    func bind3(){ //에러 옵저버블에 Retry를 붙인다면?
        button3.rx.tap.debug("button.rx.tap")
            .flatMap { _ in
                Observable<Int>.error(RxError.unknown).debug("Observable.error").retry()
            }.subscribe()
            .disposed(by: disposeBag)
    }
    
    func bind4(){ //전체 옵저버블에 Retry를 붙인다면?
        button4.rx.tap.debug("button.rx.tap")
            .flatMapLatest { _ in
                Observable<Int>.error(RxError.unknown).debug("Observable.error")
            }.retry()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func bind5(){
        button5.rx.tap.debug("button.rx.tap")
            .flatMapLatest { _ in
                Observable<Int>.error(RxError.unknown).debug("Observable.error")
                    .do(onError: { (error) in
                        let alert = UIAlertController(title: "error",
                                                      message: error.localizedDescription,
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
            }.retry()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func bind6() {
        button6.rx.tap.debug("button.rx.tap")
            .flatMap { _ in
                Observable<Int>.error(RxError.unknown).debug("Observable.error")
                    .catchErrorJustReturn(100)
            }.debug("chain").subscribe()
            .disposed(by: disposeBag)
    }
    
    func bind7(){
        button7.rx.tap.debug("button.rx.tap")
            .flatMap { _ in
                Observable<Int>.error(RxError.unknown).debug("Observable.error")
                    .catchError{ (error) -> Observable<Int> in
                        return Observable.just(error._code)
                }
            }.debug("chain").subscribe()
            .disposed(by: disposeBag)
    }
}

