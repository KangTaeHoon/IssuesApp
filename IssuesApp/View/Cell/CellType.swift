//
//  CellType.swift
//  IssuesApp
//
//  Created by 강태훈 on 2018. 4. 28..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit

protocol CellType {
    associatedtype Item
    func update(data: Item)
    static var cellFromNib: Self { get }
}

extension CellType where Self: UICollectionViewCell{ //'S'elf는 프로토콜에만 쓸수있음
    static var cellFromNib: Self {
        guard let cell = Bundle.main
            .loadNibNamed(String(describing: Self.self),
                          owner: nil,
                          options: nil)?.first as? Self else {
                            return Self()
        }
        return cell
    }
}
