//
//  AppDelegate.swift
//  IssuesApp
//
//  Created by 강태훈 on 2018. 4. 21..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        LoginViewController.register()
        //토큰을 확인해서 로그인이 안되어있으면 띄울것임.
        return true
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.host == "oauth-callback") {
            OAuthSwift.handle(url: url)
        }
        return true
    }

}

