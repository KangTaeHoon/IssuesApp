//
//  PreferenceManager.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 8..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import Foundation
import RxSwift

final class PreferenceManager {
    
    enum Constants: String {
        case tokenKey
        case refreshTokenKey
        case historyKey
        case lastRepoKey
    }
    
    fileprivate var tokenSubject: BehaviorSubject<String?> = BehaviorSubject(value: UserDefaults.standard.string(forKey: Constants.tokenKey.rawValue))
    
    var token: String? {
        get{
            let token = UserDefaults.standard.string(forKey: Constants.tokenKey.rawValue)
            return token
        }
        set{
            UserDefaults.standard.set(newValue, forKey: Constants.tokenKey.rawValue)
            tokenSubject.onNext(newValue)
        }
    }
    
    var refreshToken: String? {
        get{
            let refreshToken = UserDefaults.standard.string(forKey: Constants.refreshTokenKey.rawValue)
            return refreshToken
        }
        set{
            UserDefaults.standard.set(newValue, forKey: Constants.refreshTokenKey.rawValue)
        }
    }
    
    var history: Repos{
        get{
            let repos = (UserDefaults.standard.array(forKey: Constants.historyKey.rawValue) as? [[String:String]]) ?? []
            return Repos(dictArray: repos)
        }
    }
    
    func addToHistory(owner: String, repo: String){
        let repo = Repo(repo: repo, owner: owner)
        let repos = self.history.add(repo: repo)
        UserDefaults.standard.set(repos.dictArray, forKey: Constants.historyKey.rawValue)
    }
    
    var lastRepo: Repo?{
        get{
            guard let repoDict = UserDefaults.standard.dictionary(forKey: Constants.lastRepoKey.rawValue) as? [String: String] else {return nil}
            guard let repo = Repo(dict: repoDict) else {return nil}
            return repo
        }
    }
    
    func setLastRepo(owner: String, repo: String){
        let repo = Repo(repo: repo, owner: owner)
        UserDefaults.standard.set(repo.dict, forKey: Constants.lastRepoKey.rawValue)
    }
}

extension PreferenceManager: ReactiveCompatible {} //이런 타입을 따른다.

extension Reactive where Base: PreferenceManager {
    var token: Observable<String?> {
        return base.tokenSubject.asObservable()
    }
}

struct Repo {
    var repo: String
    var owner: String
}

extension Repo: Equatable, Hashable {
    init?(dict: [String: String]) {
        guard let repoString = dict["repo"] else { return nil}
        guard let ownerString = dict["owner"] else { return nil }
        repo = repoString
        owner = ownerString
    }
  
    static func ==(lhs: Repo, rhs: Repo) -> Bool {
        return lhs.repo == rhs.repo && lhs.owner == rhs.owner
    }
  
    var hashValue: Int {
        return repo.hashValue ^ owner.hashValue
    }
  
    var dict: [String: String] {
        return ["repo": repo, "owner": owner]
    }
}

struct Repos {
    var repos: [Repo]
}

extension Repos {
    init(dictArray: [[String : String]]) {
        repos = dictArray.flatMap { Repo(dict: $0) }
    }
  
    func add(repo: Repo) -> Repos {
        let newRepos: [Repo] = Set<Repo>(repos + [repo]).map{$0}
        return Repos(repos: newRepos)
    }
  
    var dictArray: [[String : String]] {
        return self.repos.map {
          $0.dict
        }
    }
}
