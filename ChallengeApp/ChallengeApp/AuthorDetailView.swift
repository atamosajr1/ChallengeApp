//
//  AuthorDetailView.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 22/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import UIKit

class AuthorDetailView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  @IBOutlet private var avatarImageView: UIImageView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var locationLabel: UILabel!
  @IBOutlet var phoneLabel: UILabel!
  @IBOutlet var websiteLabel: UILabel!
  @IBOutlet var loadingView: UIView!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var postsTableView: UITableView!
  
  func setDetails(author: Author) {
    nameLabel.text = "\(author.first_name!) \(author.last_name!)"
    avatarImageView.loadImageUsingCacheWithURLString(author.avatar_link!, placeHolder: UIImage(named: "dummy"))
    phoneLabel.text = author.phone
    websiteLabel.text = author.website
    locationLabel.text = author.address
  }
  
}
