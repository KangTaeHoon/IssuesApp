//
//  API.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 8..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift
import Alamofire

struct API {
  let githubOAuth: OAuth2Swift = OAuth2Swift(
    consumerKey:    "c13e3be57d10ba22f710",
    consumerSecret: "4b89b02ae81ff035d7e8cc81ee2616dd7d03fcd5",
    authorizeUrl:   "https://github.com/login/oauth/authorize",
    accessTokenUrl: "https://github.com/login/oauth/access_token",
    responseType:   "code"
  )
  
  var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
  }
  
    func getToken() -> Observable<(String, String)> {
        
        return Observable<(String, String)>.create { (observer) -> Disposable in
            
            //struct는 복사하기때문에 retain 개념이없음. 그냥 self 쓰면된다.
            self.githubOAuth.authorize(withCallbackURL: URL(string: "IssuesApp://oauth-callback/github")!,
                                       scope: "user, repo",
                                       state: "state",
                                       success: { (credential, _, _) in
                                        
                                        let oathToken = credential.oauthToken
                                        let refreshToken = credential.oauthRefreshToken
                                        observer.onNext((oathToken, refreshToken)) //한 번만 전달되면 되니까 바로 컴플릿.
                                        observer.onCompleted()
            },
                                       failure: { (error) in
                                        observer.onError(error)
            })
            return Disposables.create {}
        }
    }
    
    func repoIssues(pageID: Int) -> ((String, String)) -> Observable<[Model.Issue]> {
        
        return { (arg) in
            let (owner, repo) = arg
            let parameters: Parameters = ["page": pageID, "state": "all"]
            
            return Router.repoIssues(owner: owner, repo: repo)
                .buildRequest(parameters: parameters)
                .map { (data) -> [Model.Issue] in
                    let issues = (try? self.decoder.decode([Model.Issue].self, from: data)) ?? []
                    return issues
            }
        }
    }
    
    func issueComments(pageID: Int) -> ((String, String, Int)) -> Observable<[Model.Comment]> {
        
        return { (arg0) -> Observable<[Model.Comment]> in
            
            let (owner, repo, number) = arg0
            let parameter = ["page": pageID]
            
            return Router.issueComments(owner: owner, repo: repo, number: number)
            .buildRequest(parameters: parameter)
            .map{ (data) -> [Model.Comment] in
                guard let comments = try? self.decoder.decode([Model.Comment].self, from: data) else { return [] }
                return comments
            }
        }
    }
    
    func editIssue(owner: String, repo: String, issue: Model.Issue) -> Observable<Model.Issue>{
        guard let issueDict = try? issue.asDictionary() else {return Observable.empty()}
        return Router.editIssue(owner: owner, repo: repo, number: issue.number).buildRequest(parameters: issueDict)
            .flatMap{ (data) -> Observable<Model.Issue> in
                guard let issue  = try? self.decoder.decode(Model.Issue.self, from: data) else {
                    return Observable.error(RxError.noElements)
                }
        return Observable.just(issue)
        }
    }
    
    func postComment(owner: String, repo: String, number: Int, comment: String) -> Observable<Model.Comment> {
        let parameters: Parameters = ["body": comment]
        return Router.postComment(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters)
            .flatMap{ data -> Observable<Model.Comment> in
                guard let comment = try? self.decoder.decode(Model.Comment.self, from: data) else {
                    return Observable.error(RxError.unknown)
                }
                return Observable.just(comment)
            }
    }
    
    func postIssue(owner: String, repo: String, title: String, body: String) -> Observable<Model.Issue> {
        let parameters: Parameters = ["title": title, "body": body]
        return Router.postIssue(owner: owner, repo: repo).buildRequest(parameters: parameters)
            .flatMap{ data -> Observable<Model.Issue> in
                guard let issue = try? self.decoder.decode(Model.Issue.self, from: data) else {
                    return Observable.error(RxError.unknown)
                }
            return Observable.just(issue)
        }
    }

 
}
