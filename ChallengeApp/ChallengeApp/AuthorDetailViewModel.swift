//
//  AuthorDetailViewModel.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 12/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import UIKit
import CoreData

protocol AuthorDetailViewModelInputs {
  func viewDidLoad()
  func phoneTapped(phone: String)
  func websiteTapped(website: String)
  func loadUserDetail(author_id: String)
}

protocol AuthorDetailViewModelOutputs: class {
  var reloadData: (() -> Void) { get set }
}

protocol AuthorDetailViewModelType {
  var inputs: AuthorDetailViewModelInputs { get }
  var outputs: AuthorDetailViewModelOutputs { get }
}

final class AuthorDetailViewModel: AuthorDetailViewModelInputs, AuthorDetailViewModelOutputs, AuthorDetailViewModelType {
  let apiManager = ApiManager()
  let coreDataManager = CoreDataManager.sharedManager
  var authors: [Author]
  var author: Author
  var posts: [Post]
  
  init(author: Author) {
    self.author = author
    posts = [Post]()
    authors = [Author]()
  }
  
  // MARK: - AuthorDetailViewModel
  var inputs: AuthorDetailViewModelInputs { return self }
  var outputs: AuthorDetailViewModelOutputs { return self }
  
  func viewDidLoad() {
    getPosts(userId: author.author_id!)
  }
  
  func phoneTapped(phone: String) {
    if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
      if #available(iOS 10, *) {
        UIApplication.shared.open(url)
      } else {
        UIApplication.shared.openURL(url)
      }
    }
  }
  
  func websiteTapped(website: String) {
    if let url = URL(string: website),
      UIApplication.shared.canOpenURL(url) {
      if #available(iOS 10, *) {
        UIApplication.shared.open(url, options: [:])
      } else {
        UIApplication.shared.openURL(url)
      }
    }
  }
  
  func loadUserDetail(author_id: String) {
    posts.removeAll()
    reloadData()
    getPosts(userId: author_id)
  }
  
  // MARK: - AuthorDetailViewModelOutputs
  var reloadData: (() -> Void) = {
  }
  
  // MARK: - Private Method
  func getPosts(userId: String) {
    if Reachability.isConnectedToNetwork() {
      guard let url = URL(string: "https://gorest.co.in/public-api/posts?user_id=\(userId)") else { return }
      apiManager.requestHttpHeaders.add(value: "Authorization", forKey: "Bearer v6gJMLYHd6yL17qM1JVb6eWCF-XitBBu6vHB")
      apiManager.makeRequest(toURL: url, withHttpMethod: .get) {[weak self]  (results) in
        guard let data = results.data else {
          print("URLSession dataTask error:", results.error ?? "nil")
          return
        }
        do {
          let mainContext: NSManagedObjectContext
          if #available(iOS 10, *) {
            mainContext = self!.coreDataManager.persistentContainer.newBackgroundContext()
          } else {
            mainContext = self!.coreDataManager.context
          }
          let decoder = JSONDecoder()
          if let context = CodingUserInfoKey.context {
            decoder.userInfo[context] = mainContext
          }
          let response = try decoder.decode(PostResponse.self, from: data)
          self?.posts = response.result
          self!.coreDataManager.savePostsInCoreDataWith(array: self!.posts)
          self?.reloadData()
        } catch {
          print("JSONSerialization error:", error)
        }
      }
    } else {
      self.posts = coreDataManager.fetchPostForUser(userid: userId)
      self.reloadData()
    }
  }
}
