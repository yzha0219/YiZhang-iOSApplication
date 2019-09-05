//
//  AddLocationAnnotationDelegate.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 31/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import Foundation
import MapKit
protocol AddLocationDelegate {
    func addLocation(location: Location) -> Bool
}

protocol MapDelegate: AnyObject {
    func focusOn(annotation: MKAnnotation)
    func removeAnnotation(annotation: MKAnnotation)
    func addAnnotation(annotation: MKAnnotation)
    func reloadAnnotation()
    func removeAnnotation(allLocation: [Location])
}
