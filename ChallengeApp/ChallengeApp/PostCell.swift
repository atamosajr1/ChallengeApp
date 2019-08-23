//
//  PostCell.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 22/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
  @IBOutlet private var postTitleLabel: UILabel!
  @IBOutlet private var postBodyTextView: UITextView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  func setUpDetail(post: Post) {
    postTitleLabel.text = post.title
    postBodyTextView.text = post.body
  }
}
