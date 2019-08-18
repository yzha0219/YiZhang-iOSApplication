//
//  Annotation+CoreDataProperties.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 19/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//
//

import Foundation
import CoreData


extension Annotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Annotation> {
        return NSFetchRequest<Annotation>(entityName: "Annotation")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var desc: String?
    @NSManaged public var icon: NSData?

}
