//
//  ModelViewControllerType.swift
//  IssuesApp
//
//  Created by 강태훈 on 2018. 5. 12..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ModelViewControllerType: ReactiveCompatible, ViewControllerFromStoryBoard{
    associatedtype ReturnType
    var closeButton: UIBarButtonItem! { get set }
    func returnObservable() -> Observable<ReturnType>
}

extension Reactive where Base: ModelViewControllerType, Base: UIViewController {
    
    fileprivate static func create(parent: UIViewController?, animated: Bool = true) -> Observable<Base> {
        
        return Observable<Base>.create{ (observer) -> Disposable in
            let viewController = Base.viewController
            let dismissDisposable = viewController.closeButton.rx.tap.take(1).subscribe(onNext: { [weak viewController] _ in
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
    
    static func create(parent: UIViewController?, animated: Bool = true) -> Observable<Base.ReturnType> {
        return self.create(parent: parent, animated: animated).flatMap{ (viewController: Base) -> Observable<Base.ReturnType> in
            viewController.rx.done
            }.take(1)
    }
    
    var done: Observable<Base.ReturnType> {
        return base.returnObservable()
    }
    
    
}
