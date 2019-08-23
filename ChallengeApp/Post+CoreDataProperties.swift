//
//  Post+CoreDataProperties.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 21/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var body: String?
    @NSManaged public var edit_link: String?
    @NSManaged public var original_link: String?
    @NSManaged public var post_id: String?
    @NSManaged public var title: String?
    @NSManaged public var user_id: String?

  enum CodingKeys: String, CodingKey {
    case body
    case edit_link
    case original_link
    case post_id = "id"
    case title
    case user_id
    case links = "_links"
  }
  
  enum LinkKeys: String, CodingKey {
    case original = "self"
    case edit
    case href
  }
}

extension Post {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(body, forKey: .body)
    try container.encode(post_id, forKey: .post_id)
    try container.encode(title, forKey: .title)
    try container.encode(user_id, forKey: .user_id)
    var links = container.nestedContainer(keyedBy: LinkKeys.self, forKey: .links)
    var origLink = links.nestedContainer(keyedBy: LinkKeys.self, forKey: .original)
    var editLink = links.nestedContainer(keyedBy: LinkKeys.self, forKey: .edit)
    try origLink.encode(original_link, forKey: .href)
    try editLink.encode(edit_link, forKey: .href)
  }
}
