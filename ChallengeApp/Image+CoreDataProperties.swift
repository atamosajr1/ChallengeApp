//
//  Image+CoreDataProperties.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 23/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var location: String?
    @NSManaged public var data: NSData?

}
