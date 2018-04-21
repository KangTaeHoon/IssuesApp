//
//  Router.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 9..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

enum Router {
    case repoIssues(owner: String, repo: String)
}

extension Router {

    static let baseURLString: String = "https://api.github.com"
    
    var path: String{
        switch self {
        case let .repoIssues(owner, repo):
            return "/repos/\(owner)/\(repo)/issues"
        }
    }
    
    var url: URL{
        let url = try! Router.baseURLString.asURL()
        return url.appendingPathComponent(path)
    }
    
    var method: HTTPMethod{
        switch self {
        case .repoIssues:
            return .get
        }
    }
    
    var parameterEncoding: ParameterEncoding{
        switch self {
        case .repoIssues:
            return URLEncoding.default
        }
    }
    
    static var defaultHeaders: HTTPHeaders{
        var headers: HTTPHeaders = [:]
        if let token = App.preferenceManager.token, !token.isEmpty{
            headers["Authorization"] = "token \(token)"
        }
        return headers
    }
    
    func buildRequest(parameters: Parameters) -> Observable<Data> {
        
        print(self.url.absoluteString)
        return Router.manager.rx
        
        .request(self.method, self.url,
                 parameters: parameters,
                 encoding: self.parameterEncoding,
                 headers: Router.defaultHeaders)
        .validate(statusCode: 200 ..< 300)
        .data()
        .observeOn(MainScheduler.instance)
    }
    
    static let manager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
}
