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
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        button.rx.tap.debug("button.rx.tap")
            .flatMap { _ in
                
                Observable<Int>.error(RxError.unknown).debug("Observable<Int>.error(RxError.unknown)")
                    .catchError{ error -> Observable<Int> in
                    Observable.just(error._code)
                }

                //타입을 아무거나 넣은거임
//                Observable<Int>.error(RxError.unknown).debug("Observable<Int>.error(RxError.unknown)").catchErrorJustReturn(100)
//                Observable<Int>.error(RxError.unknown).debug("Observable.error(RxError.unknown)")
//                    .retry(2)
//                    .do(onError: { error in
//                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                })
//                Observable.just(1).debug("Observable.just(1)")
        }.debug("chain").subscribe().disposed(by: disposeBag)
    }
}
