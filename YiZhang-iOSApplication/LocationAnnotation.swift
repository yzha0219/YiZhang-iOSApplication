//
//  LocationAnnotation.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 31/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var address: String?
    var desc: String?
    var icon: String?
    var photo: String?
    
    init(title: String,address: String,desc: String,icon: String,photo: String,lat: Double,long: Double) {
        self.title = title
        self.address = address
        self.desc = desc
        self.icon = icon
        self.photo = photo
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    init(title: String, lat: Double, long: Double) {
        self.title = title
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
