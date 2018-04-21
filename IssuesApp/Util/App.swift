//
//  App.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 8..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift

struct App {
  static let api: API = API()
  static let preferenceManager: PreferenceManager = PreferenceManager()
  static let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
}

extension App {
  static func showAlert(title: String?,
                        message: String?,
                        buttonTitle: String,
                        onView viewController: UIViewController?) -> Observable<Void> {
    return Observable<Void>.create{ (observer) -> Disposable in
      let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: buttonTitle,
                                    style: UIAlertActionStyle.cancel,
                                    handler: nil))
      viewController?.present(alert, animated: true, completion: nil)
      return Disposables.create {}
    }
  }
}
