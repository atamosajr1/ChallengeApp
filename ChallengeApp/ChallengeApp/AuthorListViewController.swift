//
//  AuthorListViewController.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 02/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import UIKit

class AuthorListViewController: UIViewController {

  
  typealias Alert = AuthorListViewModel.Alert
  @IBOutlet private var authorTableView: UITableView!
  @IBOutlet private var loadingView: UIView!
  @IBOutlet private var activityIndicator: UIActivityIndicatorView!
  private var viewModel: AuthorListViewModel = AuthorListViewModel(authors: [])
  var selectedAuthor: Author? = nil
  var currentPage = 1
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toDetail" {
      if let destinationVC = segue.destination as? AuthorDetailViewController {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        destinationVC.selectedAuthor = selectedAuthor
        destinationVC.authors = viewModel.authors
      }
    }
  }

  override func viewDidLoad() {
    self.title = "Authors"
    super.viewDidLoad()
    activityIndicator.startAnimating()
    bind()
    viewModel.inputs.viewDidLoad()
  }
    
  private func bind() {
    viewModel.outputs.reloadData = { [weak self] in
      DispatchQueue.main.async {
        self?.view.sendSubviewToBack(self!.loadingView)
        self?.authorTableView.reloadData()
      }
    }
  }
  
  @objc
  func loadDataDelayed() {
    if Reachability.isConnectedToNetwork(){
      self.view.bringSubviewToFront(self.loadingView)
      currentPage += 1
      viewModel.inputs.loadMore(page: currentPage)
    }
  }
}

extension AuthorListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.authors.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let author = viewModel.authors[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "authorCell", for: indexPath) as! AuthorCell
    cell.setAuthorData(author: author )
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let author = viewModel.authors[indexPath.row]
    selectedAuthor = author
    self.performSegue(withIdentifier: "toDetail", sender: nil)
  }
}

extension AuthorListViewController: UIScrollViewAccessibilityDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
    if endScrolling >= scrollView.contentSize.height {
      self.perform(#selector(loadDataDelayed), with: nil, afterDelay: 1.0)
    }
  }
}
