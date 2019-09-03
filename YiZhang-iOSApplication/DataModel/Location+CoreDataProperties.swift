//
//  Location+CoreDataProperties.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 3/9/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//
//

import Foundation
import CoreData

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var address: String?
    @NSManaged public var desc: String?
    @NSManaged public var icon: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longtitude: Double
    @NSManaged public var name: String?
    @NSManaged public var photo: String?

}
