//
//  IssueCell.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 23..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

//final 붙이는 이유:  associatedtype타입을 쓰면 클래스에서 상속이안됨, Self도..
final class IssueCell: UICollectionViewCell, CellType {
    @IBOutlet var stateButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var commentCountButton: UIButton!
}

extension IssueCell {
    
    func update(data issue: Model.Issue) {
        titleLabel.text = issue.title
        let createdAt = issue.createdAt?.string(dateFormat: "dd MMM yyyy") ?? "-"
        contentLabel.text = "#\(issue.number) \(issue.state) on \(createdAt) by \(issue.user.login)"
        commentCountButton.setTitle("\(issue.comments)", for: .normal)
        stateButton.isSelected = issue.state == .closed
        let commentCountHidden: Bool = issue.comments == 0
        commentCountButton.isHidden = commentCountHidden
    }
}
