//
//  AuthorDetailViewController.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 12/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import UIKit
import CoreData

class AuthorDetailViewController: UIViewController {

  var isSwipe = false
  var currentIndex = 0
  var selectedAuthor: Author? = nil
  var authors: [Author] = [Author]()
  private var viewModel: AuthorDetailViewModel = AuthorDetailViewModel(author: Author.init(entity: NSEntityDescription.entity(forEntityName: "Author", in: CoreDataManager.sharedManager.context)!, insertInto: CoreDataManager.sharedManager.context))
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.title = "Author Detail"
        // Do any additional setup after loading the view.
      setupControls(author: selectedAuthor!)
      bind()
      viewModel.inputs.viewDidLoad()
    }
  private func bind() {
    viewModel.outputs.reloadData = { [weak self] in
      DispatchQueue.main.async {
        if let detailView = self?.view as? AuthorDetailView {
          detailView.postsTableView.reloadData()
          if self!.isSwipe == false {
            detailView.loadingView.isHidden = true
          } else {
            self!.isSwipe = false
          }
        }
      }
    }
  }
  
  func setupControls(author: Author) {
    viewModel = AuthorDetailViewModel(author: author)
    DispatchQueue.main.async {
      if let detailView = self.view as? AuthorDetailView {
        detailView.setDetails(author: author)
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(self.phoneTapped(_:)))
        detailView.phoneLabel.addGestureRecognizer(phoneTap)
        let websiteTap = UITapGestureRecognizer(target: self, action: #selector(self.websiteTapped(_:)))
        detailView.websiteLabel.addGestureRecognizer(websiteTap)
        let left = UISwipeGestureRecognizer(target : self, action : #selector(self.leftSwipe))
        left.direction = .left
        detailView.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(self.rightSwipe))
        right.direction = .right
        detailView.addGestureRecognizer(right)
        detailView.loadingView.isHidden = false
        detailView.activityIndicator.startAnimating()
      }
    }
  }

  @objc
  func phoneTapped(_ sender: UITapGestureRecognizer) {
    viewModel.inputs.phoneTapped(phone: (selectedAuthor?.phone)!)
  }
  
  @objc
  func websiteTapped(_ sender: UITapGestureRecognizer) {
    viewModel.inputs.websiteTapped(website: (selectedAuthor?.website)!)
  }
  
  @objc
  func leftSwipe(){
    //next
    if currentIndex < authors.count - 1 {
      isSwipe = true
      currentIndex += 1
      let currentAuthor = authors[currentIndex]
      setupControls(author: currentAuthor)
      bind()
      viewModel.inputs.loadUserDetail(author_id: currentAuthor.author_id!)
    }
  }
  
  @objc
  func rightSwipe(){
    //previous
    if currentIndex > 0 {
      isSwipe = true
      currentIndex  -= 1
      let currentAuthor = authors[currentIndex]
      setupControls(author: currentAuthor)
      bind()
      viewModel.inputs.loadUserDetail(author_id: currentAuthor.author_id!)
    }
  }
}

extension AuthorDetailViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.posts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let post = viewModel.posts[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
    cell.setUpDetail(post: post)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 355
  }
}
