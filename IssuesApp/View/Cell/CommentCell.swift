//
//  IssueCommentCell.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import AlamofireImage

final class CommentCell: UICollectionViewCell, CellType {
  @IBOutlet var bodyLabel: UILabel!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var profileImageView: UIImageView!
  @IBOutlet var commentContanerView: UIView!
  
  override func awakeFromNib() {
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    commentContanerView.layer.borderWidth = 1
    commentContanerView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
  }
}

extension CommentCell {
  typealias Item = Model.Comment
  func update(data comment: Model.Comment) {
    if let url = comment.user.avatarURL {
      profileImageView.af_setImage(withURL: url)
    }
    
    let createdAt = comment.createdAt?.string(dateFormat: "dd MM yyyy") ?? "-"
    titleLabel.text = "\(comment.user.login) commented on \(createdAt)"
    bodyLabel.text = comment.body
  }
}
