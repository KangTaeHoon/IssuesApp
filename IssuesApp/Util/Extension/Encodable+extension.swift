//
//  Encodable+extension.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 24..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import Foundation

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}
