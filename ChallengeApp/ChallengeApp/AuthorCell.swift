//
//  AuthorCell.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 22/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import UIKit
let imageCache = NSCache<NSString, UIImage>()
let coreDataManager = CoreDataManager.sharedManager

class AuthorCell: UITableViewCell {

  @IBOutlet private var authorImageView: UIImageView!
  @IBOutlet private var authorNameLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      authorNameLabel.text = ""
      authorImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  func setAuthorData(author: Author) {
    authorNameLabel.text = "\(author.first_name!) \(author.last_name!)"
    authorImageView.loadImageUsingCacheWithURLString(author.avatar_link!, placeHolder: UIImage(named: "dummy"))
  }
}

extension UIImageView {
  func loadImageUsingCacheWithURLString(_ URLString: String, placeHolder: UIImage?) {
    self.image = nil
    if Reachability.isConnectedToNetwork() {
      if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
        self.image = cachedImage
        return
      }
      
      if let url = URL(string: URLString) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
          if error != nil {
            print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
            DispatchQueue.main.async {
              self.image = placeHolder
            }
            return
          }
          if let data = data {
            DispatchQueue.main.async {
              if let downloadedImage = UIImage(data: data) {
                imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                self.image = downloadedImage
                coreDataManager.saveImage(image: self.image!, location: URLString)
              }
            }
          }
        }).resume()
      }
    }  else {
      self.image = coreDataManager.getImageWithLocation(location: URLString)
    }
  }
}
