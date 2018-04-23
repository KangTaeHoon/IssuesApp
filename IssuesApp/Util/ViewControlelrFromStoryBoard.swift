//
//  ViewControlelrFromStoryBoard.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 8..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit

protocol ViewControllerFromStoryBoard {}

//자기 자신을 생성한다. Self = UIViewController type.
extension ViewControllerFromStoryBoard where Self: UIViewController {
  static var viewController: Self {
    guard let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: String(describing: Self.self)) as? Self //Self.self = 해당 클래스네임이 스트링으로 들어감.
      else { return Self() }
    return viewController
  }
}
