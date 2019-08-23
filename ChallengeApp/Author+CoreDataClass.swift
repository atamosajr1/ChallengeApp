//
//  Author+CoreDataClass.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 02/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//
//

import Foundation
import CoreData

extension CodingUserInfoKey {
  static let context = CodingUserInfoKey(rawValue: "context")
}

public class Author: NSManagedObject,Codable {

  required convenience public init(from decoder: Decoder) throws {
    // Create NSEntityDescription with NSManagedObjectContext
    guard let contextUserInfoKey = CodingUserInfoKey.context,
      let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
      let entity = NSEntityDescription.entity(forEntityName: "Author", in: managedObjectContext) else {
        fatalError("Failed to decode Person!")
    }
    self.init(entity: entity, insertInto: nil)
    
    // Decode
    let values = try decoder.container(keyedBy: CodingKeys.self)
    address = try values.decode(String.self, forKey: .address)
    author_id = try values.decode(String.self, forKey: .author_id)
    
    dob = try values.decode(String.self, forKey: .dob)
    
    email = try values.decode(String.self, forKey: .email)
    first_name = try values.decode(String.self, forKey: .first_name)
    gender = try values.decode(String.self, forKey: .gender)
    last_name = try values.decode(String.self, forKey: .last_name)
    
    phone = try values.decode(String.self, forKey: .phone)
    status = try values.decode(String.self, forKey: .status)
    website = try values.decode(String.self, forKey: .website)
    
    let links = try values.nestedContainer(keyedBy: LinkKeys.self, forKey: .links)
    
    let origLink = try links.nestedContainer(keyedBy: LinkKeys.self, forKey: .original)
    let editLink = try links.nestedContainer(keyedBy: LinkKeys.self, forKey: .edit)
    let avatarLink = try links.nestedContainer(keyedBy: LinkKeys.self, forKey: .avatar)
    
    original_link = try origLink.decode(String.self, forKey: .href)
    edit_link = try editLink.decode(String.self, forKey: .href)
    avatar_link = try avatarLink.decode(String.self, forKey: .href)
    
  }
}
