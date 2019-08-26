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

extension NSPersistentStoreCoordinator {
  public enum CoordinatorError: Error {
    case modelFileNotFound
    case modelCreationError
    case storePathNotFound
  }
  static func coordinator(name: String) throws -> NSPersistentStoreCoordinator? {
    guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
      throw CoordinatorError.modelFileNotFound
    }
    guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
      throw CoordinatorError.modelCreationError
    }
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
      throw CoordinatorError.storePathNotFound
    }
    do {
      let url = documents.appendingPathComponent("\(name).sqlite")
      let options = [ NSMigratePersistentStoresAutomaticallyOption : true,
                      NSInferMappingModelAutomaticallyOption : true ]
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
    } catch {
      throw error
    }
    return coordinator
  }
}


class CoreDataManager: NSObject {
  static let sharedManager = CoreDataManager()
  private override init() {}
  
  @available(iOS 10.0, *)
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "ChallengeApp")
    //print(container.persistentStoreDescriptions.first?.url)
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
      }
    })
    let description = NSPersistentStoreDescription()
    description.shouldMigrateStoreAutomatically = true
    description.shouldInferMappingModelAutomatically = true
    container.persistentStoreDescriptions =  [description]
    return container
  }()
  
  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    do {
      return try NSPersistentStoreCoordinator.coordinator(name: "ChallengeApp")
    } catch {
      print("CoreData: Unresolved error \(error)")
    }
    return nil
  }()
  
  private lazy var managedObjectContext: NSManagedObjectContext = {
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
  
  var context: NSManagedObjectContext {
    get {
      if #available(iOS 10.0, *) {
        return persistentContainer.viewContext
      } else {
        return managedObjectContext
      }
    }
  }
  
  func saveContext () {
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
    if let authorEntity = NSEntityDescription.insertNewObject(forEntityName: "Author", into: context) as? Author {
      print("Create : \(author.first_name)")
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
      try context.save()
    } catch let error {
      print(error)
    }
  }
  
  func fetchAllAuthors()  -> [Author] {
    do {
      let filter = NSPredicate(format: "author_id != nil")
      let sortDescriptor = NSSortDescriptor(key: "author_id", ascending: true)
      let sortDescriptors = [sortDescriptor]
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Author.self))
      fetchRequest.sortDescriptors = sortDescriptors
      fetchRequest.predicate = filter
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
      try context.save()
    } catch let error {
      print(error)
    }
  }
  
  func fetchPostForUser(userid: String) -> [Post] {
    var posts: [Post] = [Post]()
    let filter = NSPredicate(format: "user_id contains %@", userid)
    do {
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
    if let imageEntity = NSEntityDescription.insertNewObject(forEntityName: "Image", into: context) as? Image {
      let imageData = image.jpegData(compressionQuality: 1.0)
      imageEntity.location = location
      imageEntity.data = imageData! as NSData
      do {
        try context.save()
      } catch let error {
        print(error)
      }
    }
  }
  
  func getImageWithLocation(location: String) -> UIImage {
    let filter = NSPredicate(format: "location = %@", location)
    do {
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
