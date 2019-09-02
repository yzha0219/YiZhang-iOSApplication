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
        //1
        let imag1 = UIImage(named: "Melbourne_Museum.png")
        let imageData1: NSData = imag1!.pngData()! as NSData
        let icon1 = UIImage(named: "museum.png")
        let iconData1: NSData = icon1!.pngData()! as NSData
        let _ = addLocation(name: "Melbourne Museum", desc: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives.", address: "11 Nicholson Street, Carlton, Victoria, 3053", photo: imageData1, icon: iconData1)
        //2
        let imag2 = UIImage(named: "Werribee Park and Mansion.png")
        let imageData2: NSData = imag2!.pngData()! as NSData
        let icon2 = UIImage(named: "park.png")
        let iconData2: NSData = icon2!.pngData()! as NSData
        let _ = addLocation(name: "Werribee Park and Mansion", desc: "Enjoy a perfect day out at Werribee Park. Experience the grandeur of Werribee Mansion, discover Victoria's unique pastoral history down at the farm and homestead, relax with family and friends on the Great lawn surrounded by stunning formal gardens, and so much more.", address: "K Road, Gate 2, Werribee Park, Werribee, Victoria, 3030", photo: imageData2, icon: iconData2)
        //3
        let imag3 = UIImage(named: "Brighton_Beach_Boxes.png")
        let imageData3: NSData = imag3!.pngData()! as NSData
        let icon3 = UIImage(named: "beach.png")
        let iconData3: NSData = icon3!.pngData()! as NSData
        let _ = addLocation(name: "Brighton Bathing Boxes", desc: "Dive into Port Phillip Bay under the watch of 82 distinctive bathing boxes, a row of uniformly proportioned wooden structures lining the foreshore at Brighton Beach. Built well over a century ago in response to very Victorian ideas of morality and seaside bathing, the bathing boxes remain almost unchanged. All retain classic Victorian architectural features with timber framing, weatherboards and corrugated iron roofs, though they also bear the hallmarks of individual licencees' artistic and colourful embellishments. Thanks to these distinctive decorations, the boxes turn the Brighton seaside into an immediately recognisable, iconic beachscape that can transform by the hour according to season, light and colour. Just try to resist pulling out your camera and snapping away.", address: "Dendy Street Beach, Dendy Street and the Esplanade, Brighton, Victoria, 3186", photo: imageData3, icon: iconData3)
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
