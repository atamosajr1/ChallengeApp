//
//  AuthorListViewModel.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 02/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import UIKit

protocol AuthorListViewModelInputs {
  func viewDidLoad()
  func tableViewDidSelectRow(section: Int, row: Int)
  func loadMore(page: Int)
}

protocol AuthorListViewModelOutputs: class {
  typealias Alert = AuthorListViewModel.Alert
  var reloadData: (() -> Void) { get set }
}

protocol AuthorListViewModelType {
  var inputs: AuthorListViewModelInputs { get }
  var outputs: AuthorListViewModelOutputs { get }
}

final class AuthorListViewModel: AuthorListViewModelInputs, AuthorListViewModelOutputs, AuthorListViewModelType {
  
  let apiManager = ApiManager()
  let coreDataManager = CoreDataManager.sharedManager
  var authors: [Author]
  
  init(authors: [Author]) {
    self.authors = authors
  }
  
  struct Alert {
    let title: String
    let message: String
    let completion: (() -> Void)?
  }
  
  // MARK: - AuthorListViewModelType
  var inputs: AuthorListViewModelInputs { return self }
  var outputs: AuthorListViewModelOutputs { return self }
  
  func viewDidLoad() {
    if Reachability.isConnectedToNetwork() {
      coreDataManager.clearAuthorData()
      coreDataManager.clearPostData()
    }
    getUser(page: 1)
  }
  
  func tableViewDidSelectRow(section: Int, row: Int) {
    
  }
  
  func loadMore(page: Int) {
    getUser(page: page)
  }
  
  // MARK: - AuthorListViewModelOutputs
  var reloadData: (() -> Void) = {
  }

  
  // MARK: - Private Methods
  func getUser(page: Int) {
    
    if Reachability.isConnectedToNetwork() {
      guard let url = URL(string: "https://gorest.co.in/public-api/users?page=\(page)") else { return }
      apiManager.requestHttpHeaders.add(value: "Authorization", forKey: "Bearer v6gJMLYHd6yL17qM1JVb6eWCF-XitBBu6vHB")
      apiManager.makeRequest(toURL: url, withHttpMethod: .get) {[weak self] (results) in
        guard let data = results.data else {
          print("URLSession dataTask error:", results.error ?? "nil")
          return
        }
        print("Authors : \(data)")
        do {
          let mainContext = self!.coreDataManager.persistentContainer.newBackgroundContext()
          let decoder = JSONDecoder()
          if let context = CodingUserInfoKey.context {
            decoder.userInfo[context] = mainContext
          }
          
          let response = try decoder.decode(AuthorResponse.self, from: data)
          let sortedAuthors = response.result.sorted(by: { (Obj1, Obj2) -> Bool in
            let author1 = Obj1.author_id ?? ""
            let author2 = Obj2.author_id ?? ""
            return (author1.localizedCaseInsensitiveCompare(author2) == .orderedAscending)
          })
          self?.authors.append(contentsOf: sortedAuthors)
          self!.coreDataManager.saveAuthorsInCoreDataWith(array: self!.authors)
          self?.reloadData()
        } catch {
          print("JSONSerialization error:", error)
        }
      }
    } else {
      let authors = coreDataManager.fetchAllAuthors()
      self.authors.append(contentsOf: authors)
      self.reloadData()
    }
  }
}
