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
    
    //Save change to core data
    func saveContext(){
        if persistantContainer.viewContext.hasChanges{
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    //Add Location to core data
    func addLocation(name: String, desc: String, address: String, photo: String, icon: String,lat: Double,long: Double) -> Location {
        let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: persistantContainer.viewContext) as! Location
        location.name = name
        location.desc = desc
        location.address = address
        location.photo = photo
        location.icon = icon
        location.latitude = lat
        location.longtitude = long
        saveContext()
        return location
    }
    
    //Remove Location from core data
    func removeLocation(location: Location) {
        persistantContainer.viewContext.delete(location)
        saveContext()
    }
    
    //Updata Location in core data
    func updateLocation(name: String, desc: String, address: String, photo: String, icon: String,lat: Double,long: Double) {
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: persistantContainer.viewContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        let predicate = NSPredicate(format: "(name = %@)", name)
        request.predicate = predicate
        do {
            let results =
                try persistantContainer.viewContext.fetch(request)
            let objectUpdate = results[0] as! NSManagedObject
            //objectUpdate.setValue(name, forKey: "name")
            objectUpdate.setValue(desc, forKey: "desc")
            objectUpdate.setValue(address, forKey: "address")
            objectUpdate.setValue(photo, forKey: "photo")
            objectUpdate.setValue(icon, forKey: "icon")
            objectUpdate.setValue(lat, forKey: "latitude")
            objectUpdate.setValue(long, forKey: "longtitude")
            do {
                try persistantContainer.viewContext.save()
                //labelStatus.text = "Updated"
                print("Update")
            }catch let error as NSError {
                //labelStatus.text = error.localizedFailureReason
                print(error.localizedFailureReason!)
            }
        }
        catch let error as NSError {
            //labelStatus.text = error.localizedFailureReason
            print(error.localizedFailureReason!)
        }
        saveContext()
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
        let _ = addLocation(name: "Melbourne Museum",desc: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives. The Melbourne Museum left its old home in the State Library Building in 1997, and into a building located in Carlton Gardens that was designed by Denton Corker Marshall. The new Melbourne Museum reopened on 21 October 2000. Inside, you'll find the Forest Gallery, the living heart of the museum and home to tall trees and wondrous wildlife. The Science and Life Gallery at the west end, where you'll find bugs, dinosaurs, fossils and more. Bunjilaka Aboriginal Cultural Centre, a place imbued with the living traditions and knowledge of Koorie people and other cultures from around Australia. Te Pasifika Gallery, a bright soaring space filled with treasures from the Pacific Islands.",address: "11 Nicholson Street, Carlton, Victoria, 3053",photo: "Melbourne_Museum.png",icon: "museum.png",lat: -37.804280,long: 144.973530)
        //2
        let _ = addLocation(name: "Werribee Park and Mansion",desc: "Enjoy a perfect day out at Werribee Park. Experience the grandeur of Werribee Mansion, discover Victoria's unique pastoral history down at the farm and homestead, relax with family and friends on the Great lawn surrounded by stunning formal gardens, and so much more.",address: "K Road, Gate 2, Werribee Park, Werribee, Victoria, 3030",photo: "Werribee Park and Mansion.png",icon: "park.png",lat: -37.928120,long: 144.678760)
        //3
        let _ = addLocation(name: "Brighton Bathing Boxes",desc: "Dive into Port Phillip Bay under the watch of 82 distinctive bathing boxes, a row of uniformly proportioned wooden structures lining the foreshore at Brighton Beach. Built well over a century ago in response to very Victorian ideas of morality and seaside bathing, the bathing boxes remain almost unchanged. All retain classic Victorian architectural features with timber framing, weatherboards and corrugated iron roofs, though they also bear the hallmarks of individual licencees' artistic and colourful embellishments. Thanks to these distinctive decorations, the boxes turn the Brighton seaside into an immediately recognisable, iconic beachscape that can transform by the hour according to season, light and colour. Just try to resist pulling out your camera and snapping away.",address: "Dendy Street Beach, Dendy Street and the Esplanade, Brighton, Victoria, 3186",photo: "Brighton_Beach_Boxes.png", icon: "beach.png",lat: -37.919891,long: 144.996994)
        //4
        let _ = addLocation(name: "Heide Museum of Modern Art", desc: "Heide Museum of Modern Art, or Heide as it is affectionately known, began life in 1934 as the Melbourne home of John and Sunday Reed and has since evolved into one of Australia's most unique destinations for modern and contemporary Australian art. Located just twenty minutes from the city, Heide boasts fifteen acres of beautiful gardens, three dedicated exhibition spaces, two historic kitchen gardens, a sculpture park and the Heide Store.", address: "7 Templestowe Road, Bulleen, Victoria, 3105", photo: "Heide_Museum_of Modern_Art.png", icon: "museum.png", lat: -37.757179, long: 145.083283)
        //5
        let _ = addLocation(name: "Steamrail Victoria", desc: "Steamrail Victoria is a non-profit organisation dedicated to the restoration and operation of vintage steam, diesel and electric locomotives and carriages. The Vintage Train operates monthly to destinations throughout the state. It travels all over the Victorian Railways broad gauge network offering a variety of tours for all tastes, including weekend excursions to interesting and popular destinations. The Steamrail Victoria carriage fleet comprises some thirty cars including sitting, sleeping and specialist vehicles. These vehicles date back to the early 20th century and feature comfortable seating, varnished wood panelling and opening windows. Trains have a kiosk car and most include a licensed bar. The Newport Railway Workshops were built in the 1880s and were actually the birthplace of many of their locomotives and carriages. These facilities enable them to keep their historic fleet in tiptop shape, and to carry out current restoration projects such as the precious A2 steam locomotive and vintage diesel B72.", address: "1 Shea Street, Newport, Victoria, 3015", photo: "Steamrail_Victoria.png", icon: "train.png", lat: -37.848478, long: 144.880432)
        //6
        let _ = addLocation(name: "St Michael's Uniting Church", desc: "St Michael's is a unique church in the heart of the city. It is not only unique for its relevant, contemporary preaching, but for its unusual architecture. St Michael's strives to be the best possible model of what the New Faith can be; they want to attract and sustain larger numbers of people who see that this expression of church life is the most meaningful and worthwhile experience for them. It is a place which affirms and encourages the best expression of who you are and who you can be, through relevant theology, Sunday Service, numerous support programs and its commitment to counselling and psychotherapy.", address: "120 Collins Street, Melbourne, Victoria, 3000", photo: "St_Michael's_Uniting_Church.png", icon: "church.png", lat: -37.814019, long: 144.969688)
        //7
        let _ = addLocation(name: "Rippon Lea Estate", desc: "An intact example of 19th century suburban high life, the National Heritage Listed Rippon Lea Estate is like a suburb all to itself, an authentic Victorian mansion amidst 14 acres of breathtaking gardens. Make yourself at home exploring over 20 rooms in the original estate, its sweeping heritage grounds, a picturesque lake and waterfall, an original 19th century fruit orchard and the largest fernery in the Southern Hemisphere. Keep your eyes peeled for the Gruffalo’s latest hideout. Open all year, Rippon Lea Estate is Victoria’s grandest backyard.", address: "192 Hotham Street, Elsternwick, Victoria, 3185", photo: "Rippon_Lea_Estate.png", icon: "mansion.png", lat: -37.879408, long: 144.998883)
        //8
        let _ = addLocation(name: "Como House and Garden", desc: "Built in 1847, Como House and Garden is one of Melbourne most glamorous stately homes. A unique blend of Australian Regency and classic Italianate architecture, Como House offers a rare glimpse into the opulent lifestyles of former owners, the Armytage family, who lived there for over a century. Famous among Melbourne high society for its elegant dances, dinners and receptions, the Armytage home remains furnished with original family heirlooms, and even the servant’s areas have been carefully preserved. Explore this iconic heritage landmark that stands as a world of its own, picnic in the magnificent gardens and enjoy a meal by the popular Stables of Como cafe.", address: "Corner of Williams Road and Lechlade Avenue, South Yarra, Victoria, 3141", photo: "Como_House_and_Garden.png", icon: "tree.png", lat: -37.838308, long: 145.005093)
        //9
        let _ = addLocation(name: "Old Melbourne Gaol", desc: "Step back in time to Melbourne’s most feared destination since 1845, Old Melbourne Gaol. Shrouded in secrets, wander the same cells and halls as some of history’s most notorious criminals, from Ned Kelly to Squizzy Taylor, and discover the stories that never left. Hosting day and night tours, exclusive events and kids activities throughout school holidays and an immersive lock-up experience in the infamous City Watch House, the Gaol remains Melbourne’s most spell-binding journey into its past. The Old Melbourne Gaol is a two minute walk from Melbourne Central Station. Or catch the free City Circle tram to stop number seven on the corner of La Trobe and Russell Streets.", address: "377 Russell Street, Melbourne, Victoria, 3000", photo: "Old_Melbourne_Gaol.png", icon: "handcuffs.png", lat: -37.807821, long: 144.965077)
        //10
        let _ = addLocation(name: "Melbourne's Tall Ship - Enterprize", desc: "Step aboard Melbourne's Tall Ship Enterprize and step back to a time of daring voyages and discovery. Feel the romance and excitement of sailing with the wind in your hair as you take in spectacular views of Melbourne's skyline, Port Phillip Bay and Australia's spectacular southern coast. Experience history on a magnificent handcrafted replica of John Pascoe Faulkner's Enterprize, the ship that brought the first permanent European settlers to Melbourne in 1835. Discover life as an early explorer and uncover the tale of ambition, intrigue and rivalry that led to Melbourne's foundation. Relax on deck or hoist the sails, steer the ship and climb the rigging for heart stopping thrills.         Enterprize has monthly public sails from Docklands, Williamstown, Mornington and Geelong, with sails from Portarlington during peak season and special events, such as the Mussel and Celtic Festivals.", address: "2 North Wharf Road, Docklands, Victoria, 3008", photo: "Melbourne's_Tall_Ship_Enterprize.png", icon: "ship.png", lat: -37.818944, long: 144.935160)
        //11
        let _ = addLocation(name: "Her Majesty's Theatre", desc: "Her Majesty's Theatre, one of Melbourne's most iconic venues for live performance, has been entertaining Australia since 1886. Newly restored and with ongoing renovations and improvements - including new and more comfortable seats throughout the auditorium, a modern stage house, enlarged orchestra pit and upgraded backstage facilities - Her Majesty's Theatre continues to be a truly dynamic venue, hosting musicals, plays, opera, dance, comedy and more. Its Art Deco interior boasts an impressive seating capacity of 1700 seats, yet the auditorium is renowned for its intimate setting.To add that special something to your visit, Her Majesty's Theatre has elegantly appointed private rooms and catering options available for anywhere from couples celebrating a romantic night out at the theatre, through to large groups.", address: "219 Exhibition Street, Melbourne, Victoria, 3000", photo: "Her_Majesty's_Theatre.png", icon: "theatre.png", lat: -37.810696, long: 144.969745)
        //12
        let _ = addLocation(name: "St Kilda Pier", desc: "Providing panoramic views of the Melbourne skyline and Port Phillip Bay, the pier is a popular destination for strolling, cycling, rollerblading and fishing. Catch a ferry to Williamstown, enjoy a snack at the kiosk or try to spot the penguins and native water rats from the breakwater. Whatever your preference, St Kilda Pier provides an unforgettable experience right in the heart of Melbourne. St Kilda Pier's history dates back to 1853 when the St Kilda Pier and Jetty Company constructed a wooden jetty to assist the early settlers in unloading timber, building materials and firewood to St Kilda. Not long after its construction the small jetty fell victim to a stormy Port Phillip Bay and was washed away.The historic St Kilda Pier Kiosk was built in 1904 and has undergone several renovations in its time.", address: "Pier Road, St Kilda, Victoria, 3182", photo: "St_Kilda_Pier.png", icon: "pier.png", lat: -37.862331, long: 144.971278)
        //13
        let _ = addLocation(name: "Parliament of Victoria", desc: "Victoria's Parliament House - one of Australia's oldest and most architecturally distinguished public buildings. The Parliament of Victoria welcomes you to share in our history and heritage. Sit in the chambers where Victoria's laws are made, take in the majesty of Queen's Hall, and see where Australia's first Federal Parliament conducted proceedings for 26 years. The interior features classical decoration, including an intricate mosaic of Minton floor tiles, gold-leaf, columns, statues and paintings. Free guided public tours are provided on non-sitting days.", address: "Spring Street, East Melbourne, Victoria, 3002", photo: "Parliament_of_Victoria.png", icon: "government.png", lat: -37.811043, long: 144.972997)
        //14
        let _ = addLocation(name: "Flinders Street Station", desc: "Stand beneath the clocks of Melbourne's iconic railway station, as tourists and Melburnians have done for generations. Take a train for outer-Melbourne explorations, join a tour to learn more about the history of the grand building, or go underneath the station to see the changing exhibitions that line Campbell Arcade.", address: "Corner Flinders Street and Swanston Street, Melbourne, Victoria, 3000", photo: "Flinders_Street_Station.png", icon: "train-station.png", lat: -37.817485, long: 144.967437)
        //15
        let _ = addLocation(name: "The Scots' Church", desc: "Look up to admire the 120-foot spire of the historic Scots' Church, once the highest point of the city skyline. Nestled between modern buildings on Russell and Collins streets, the decorated Gothic architecture and stonework is an impressive sight, as is the interior's timber panelling and stained glass. Trivia buffs, take note: the church was built by David Mitchell, father of Dame Nellie Melba (once a church chorister).", address: "Corner of Collins Street and Russell Street, Melbourne, Victoria, 3000", photo: "The_Scots'_Church.png", icon: "church.png", lat: -37.814751, long:  144.968955)
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        return image
    }
}
