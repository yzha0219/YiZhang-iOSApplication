//
//  Location+CoreDataProperties.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 31/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var desc: String?
    @NSManaged public var icon: NSData?
    @NSManaged public var address: String?
    @NSManaged public var name: String?
    @NSManaged public var photo: NSData?

}
