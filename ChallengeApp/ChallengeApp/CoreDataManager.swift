//
//  CoreDataManager.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 02/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager: NSObject {
  static let sharedManager = CoreDataManager()
  private override init() {}
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "ChallengeApp")
    //print(container.persistentStoreDescriptions.first?.url)
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
      }
    })
    return container
  }()
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

  func createAuthorEntityFrom(author: Author) -> NSManagedObject? {
    let context = persistentContainer.viewContext
    if let authorEntity = NSEntityDescription.insertNewObject(forEntityName: "Author", into: context) as? Author {
      authorEntity.address = author.address
      authorEntity.author_id = author.author_id
      authorEntity.avatar_link = author.avatar_link
      authorEntity.dob = author.dob
      authorEntity.edit_link = author.edit_link
      authorEntity.email = author.email
      authorEntity.first_name = author.first_name
      authorEntity.gender = author.gender
      authorEntity.last_name = author.last_name
      authorEntity.original_link = author.original_link
      authorEntity.phone = author.phone
      authorEntity.status = author.status
      authorEntity.website = author.website
      return authorEntity
    }
    return nil
  }
  
  func saveAuthorsInCoreDataWith(array: [Author]) {
    _ = array.map{self.createAuthorEntityFrom(author: $0)}
    do {
      try CoreDataManager.sharedManager.persistentContainer.viewContext.save()
    } catch let error {
      print(error)
    }
  }
  
  func fetchAllAuthors()  -> [Author] {
    do {
      let sortDescriptor = NSSortDescriptor(key: "author_id", ascending: true)
      let sortDescriptors = [sortDescriptor]
      let context = persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Author.self))
      fetchRequest.sortDescriptors = sortDescriptors
      var authors: [Author] = [Author]()
      do {
        let objects  = try context.fetch(fetchRequest) as? [Author]
        authors = objects!
      } catch let error {
        print("ERROR Fetching : \(error)")
      }
      return authors
    }
  }
  
  func clearAuthorData() {
    do {
      
      let context = persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Author.self))
      do {
        let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
        _ = objects.map{$0.map{context.delete($0)}}
        CoreDataManager.sharedManager.saveContext()
      } catch let error {
        print("ERROR DELETING : \(error)")
      }
    }
  }
  
  func createPostEntityFrom(post: Post) -> NSManagedObject? {
    let context = persistentContainer.viewContext
    if let postEntity = NSEntityDescription.insertNewObject(forEntityName: "Post", into: context) as? Post {
      postEntity.body = post.body
      postEntity.edit_link = post.edit_link
      postEntity.original_link = post.original_link
      postEntity.post_id = post.post_id
      postEntity.title = post.title
      postEntity.user_id = post.user_id
      
      return postEntity
    }
    return nil
  }
  
  func savePostsInCoreDataWith(array: [Post]) {
    _ = array.map{self.createPostEntityFrom(post: $0)}
    do {
      try CoreDataManager.sharedManager.persistentContainer.viewContext.save()
    } catch let error {
      print(error)
    }
  }
  
  func fetchPostForUser(userid: String) -> [Post] {
    var posts: [Post] = [Post]()
    let filter = NSPredicate(format: "user_id contains %@", userid)
    do {
      
      let context = persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Post.self))
      fetchRequest.predicate = filter
      do {
        let objects  = try context.fetch(fetchRequest) as? [Post]
        posts = objects!
      } catch let error {
        print("ERROR Fetching : \(error)")
      }
    }
    return posts
  }
  
  func clearPostData() {
    do {
      
      let context = persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Post.self))
      do {
        let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
        _ = objects.map{$0.map{context.delete($0)}}
        CoreDataManager.sharedManager.saveContext()
      } catch let error {
        print("ERROR DELETING : \(error)")
      }
    }
  }
  
  func saveImage(image: UIImage, location: String) {
    let context = persistentContainer.viewContext
    if let imageEntity = NSEntityDescription.insertNewObject(forEntityName: "Image", into: context) as? Image {
      let imageData = image.jpegData(compressionQuality: 1.0)
      imageEntity.location = location
      imageEntity.data = imageData! as NSData
      do {
        try CoreDataManager.sharedManager.persistentContainer.viewContext.save()
      } catch let error {
        print(error)
      }
    }
  }
  
  func getImageWithLocation(location: String) -> UIImage {
    let filter = NSPredicate(format: "location = %@", location)
    do {
      
      let context = persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Image.self))
      fetchRequest.predicate = filter
      do {
        let objects  = try context.fetch(fetchRequest) as? [Image]
        if (objects?.count)! > 0 {
          let imageEntity = objects?.first
          let imgData: NSData? = imageEntity!.data
          let returnImage: UIImage = UIImage(data: imgData! as Data)!
          return returnImage
        }
      } catch let error {
        print("ERROR Fetching : \(error)")
      }
    }
    return UIImage()
  }
  
}
