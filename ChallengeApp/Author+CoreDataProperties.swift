//
//  Author+CoreDataProperties.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 21/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//
//

import Foundation
import CoreData

extension Author {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Author> {
        return NSFetchRequest<Author>(entityName: "Author")
    }

    @NSManaged public var address: String?
    @NSManaged public var author_id: String?
    @NSManaged public var avatar_link: String?
    @NSManaged public var dob: String?
    @NSManaged public var edit_link: String?
    @NSManaged public var email: String?
    @NSManaged public var first_name: String?
    @NSManaged public var gender: String?
    @NSManaged public var last_name: String?
    @NSManaged public var original_link: String?
    @NSManaged public var phone: String?
    @NSManaged public var status: String?
    @NSManaged public var website: String?

  enum CodingKeys: String, CodingKey {
    case address
    case author_id = "id"
    case avatar_link
    case dob
    case edit_link
    case email
    case first_name
    case gender
    case last_name
    case original_link
    case phone
    case status
    case website
    case links = "_links"
    case result
  }
  
  enum LinkKeys: String, CodingKey {
    case original = "self"
    case edit
    case avatar
    case href
  }
}

extension Author {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(address, forKey: .address)
    try container.encode(author_id, forKey: .author_id)
    try container.encode(dob, forKey: .dob)
    try container.encode(email, forKey: .email)
    try container.encode(first_name, forKey: .first_name)
    try container.encode(gender, forKey: .gender)
    try container.encode(last_name, forKey: .last_name)
    try container.encode(phone, forKey: .phone)
    try container.encode(status, forKey: .status)
    try container.encode(website, forKey: .website)
    var links = container.nestedContainer(keyedBy: LinkKeys.self, forKey: .links)
    var origLink = links.nestedContainer(keyedBy: LinkKeys.self, forKey: .original)
    var editLink = links.nestedContainer(keyedBy: LinkKeys.self, forKey: .edit)
    var avatarLink = links.nestedContainer(keyedBy: LinkKeys.self, forKey: .avatar)
    try origLink.encode(original_link, forKey: .href)
    try editLink.encode(edit_link, forKey: .href)
    try avatarLink.encode(avatar_link, forKey: .href)
  }
}
