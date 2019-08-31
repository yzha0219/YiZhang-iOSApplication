//
//  CoreDataController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 30/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol,NSFetchedResultsControllerDelegate {
    
    let DEFAULT_LOCATION = "Default Location"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    //Results
    var allLocationFetchedResultsController: NSFetchedResultsController<Location>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "LocationAnnotation")
        persistantContainer.loadPersistentStores(){(description,error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        super.init()
        
        if fetchAllLocation().count == 0 {
            createDefaultEntries()
        }
    }
    
    func saveContext(){
        if persistantContainer.viewContext.hasChanges{
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    func addLocation(name: String, desc: String, address: String, photo: NSData, icon: NSData) -> Location {
        let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: persistantContainer.viewContext) as! Location
        location.name = name
        location.desc = desc
        location.address = address
        location.photo = photo
        location.icon = icon
        
        saveContext()
        return location
    }
    
    func removeLocation(location: Location) {
        persistantContainer.viewContext.delete(location)
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onLocationListChange(change: .update, location: fetchAllLocation())
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllLocation() -> [Location] {
        if allLocationFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name",ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allLocationFetchedResultsController = NSFetchedResultsController<Location>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allLocationFetchedResultsController?.delegate = self
            
            do {
                try allLocationFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var locations = [Location]()
        if allLocationFetchedResultsController?.fetchedObjects != nil {
            locations = (allLocationFetchedResultsController?.fetchedObjects)!
        }
        
        return locations
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allLocationFetchedResultsController {
            listeners.invoke{ (listener) in
                if listener.listenerType == ListenerType.location {
                    listener.onLocationListChange(change: .update, location: fetchAllLocation())
                }
            }
        }
    }
    
    func createDefaultEntries() {
        let imag = UIImage(named: "Melbourne_Museum.png")
        let imageData: NSData = imag!.pngData()! as NSData
        let icon = UIImage(named: "museum.png")
        let iconData: NSData = icon!.pngData()! as NSData
        let _ = addLocation(name: "Melbourne Museum", desc: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives.", address: "11 Nicholson Street, Carlton, Victoria, 3053", photo: imageData, icon: iconData)
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                   .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            print(filePath)
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        return image
    }


}
