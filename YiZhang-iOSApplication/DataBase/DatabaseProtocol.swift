//
//  DatabaseProtocol.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 30/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case location
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onLocationListChange(change: DatabaseChange, location: [Location])
}

protocol DatabaseProtocol: AnyObject {
    //var defaultLocationAnnotation: LocationAnnotation {get}
    func fetchAllLocation() -> [Location]
    func addLocation(name: String,desc: String,address: String,photo: String,icon: String,lat: Double,long: Double) -> Location
    func removeLocation(location: Location)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func updateLocation(name: String, desc: String, address: String, photo: String, icon: String,lat: Double,long: Double)
}
