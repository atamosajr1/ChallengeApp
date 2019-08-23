//
//  Post+CoreDataClass.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 02/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//
//
import Foundation
import CoreData


public class Post: NSManagedObject,Codable {

  required convenience public init(from decoder: Decoder) throws {
    guard let contextUserInfoKey = CodingUserInfoKey.context,
      let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
      let entity = NSEntityDescription.entity(forEntityName: "Post", in: managedObjectContext) else {
        fatalError("Failed to decode Post!")
    }
    self.init(entity: entity, insertInto: nil)
    
    // Decode
    let values = try decoder.container(keyedBy: CodingKeys.self)
    body = try values.decode(String.self, forKey: .body)
    post_id = try values.decode(String.self, forKey: .post_id)
    title = try values.decode(String.self, forKey: .title)
    user_id = try values.decode(String.self, forKey: .user_id)
    
    let links = try values.nestedContainer(keyedBy: LinkKeys.self, forKey: .links)
    
    let origLink = try links.nestedContainer(keyedBy: LinkKeys.self, forKey: .original)
    let editLink = try links.nestedContainer(keyedBy: LinkKeys.self, forKey: .edit)
    
    original_link = try origLink.decode(String.self, forKey: .href)
    edit_link = try editLink.decode(String.self, forKey: .href)
  }

}
