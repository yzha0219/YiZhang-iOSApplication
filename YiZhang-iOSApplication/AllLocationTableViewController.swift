//
//  AllAnnotationTableViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 27/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class AllLocationTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    let SECTION_LOCATIONS = 0;
    let SECTION_COUNT = 1;
    let CELL_LOCATION = "locationCell"
    let CELL_COUNT = "totalLocationCell"
    
    var allLocation: [Location] = []
    var filteredLocation: [Location] = []
    var locationDelegate: AddLocationDelegate?
    //var coreDataController : CoreDataController?
    weak var mapDelegate: MapDelegate?
    weak var databaseController: DatabaseProtocol?
    var mapViewController: MapViewController?
    var listenerType: ListenerType = ListenerType.location
    //var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        allLocation = databaseController!.fetchAllLocation()
        filteredLocation = allLocation
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Location"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    
    @IBAction func sortOption(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            //ascending
            filteredLocation = filteredLocation.sorted(by: { (item1, item2) -> Bool in
                return item1.name!.lowercased().compare(item2.name!.lowercased()) == ComparisonResult.orderedAscending
            })
        }
        else {
            //descending
            filteredLocation = filteredLocation.sorted(by: { (item1, item2) -> Bool in
                return item1.name!.lowercased().compare(item2.name!.lowercased()) == ComparisonResult.orderedDescending
            })
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onLocationListChange(change: DatabaseChange, location: [Location]) {
        allLocation = location
        mapDelegate!.reloadAnnotation()
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 {
            filteredLocation = allLocation.filter({(location: Location) -> Bool in
                return location.name!.lowercased().contains(searchText)
            })
        }
        else {
            filteredLocation = allLocation
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == SECTION_LOCATIONS {
            return filteredLocation.count
        } else {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_LOCATIONS {
            let annotationCell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath) as! LocationTableViewCell
            let annotation = filteredLocation[indexPath.row]
            annotationCell.nameLabel.text = annotation.name
            annotationCell.descLabel.text = annotation.desc
            let icon = UIImage(named: annotation.icon!)
            annotationCell.icon.image = icon
            
            return annotationCell
        }
        let countCell = tableView.dequeueReusableCell(withIdentifier: CELL_COUNT, for: indexPath)
        countCell.textLabel?.text = "\(allLocation.count) location annotations in the database"
        countCell.selectionStyle = .none
        return countCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_LOCATIONS{
            let selectedLocation = self.filteredLocation[indexPath.row]
            let title = selectedLocation.name!
            let address = selectedLocation.address!
            let desc = selectedLocation.desc!
            let icon = selectedLocation.icon!
            let phote = selectedLocation.photo!
            let lat: Double = selectedLocation.latitude
            let long: Double = selectedLocation.longtitude
            let locationAnnotation = LocationAnnotation(title: title, address: address, desc: desc, icon: icon, photo: phote, lat: lat, long: long)
            mapDelegate!.focusOn(annotation: locationAnnotation as MKAnnotation)
            navigationController?.popViewController(animated: true)
        }
        return
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_LOCATIONS {
            return true
        }
        return false
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_LOCATIONS {
            // Delete the row from the data source
            let location = self.filteredLocation[indexPath.row]
            databaseController!.removeLocation(location: location)
            //mapDelegate!.reloadAnnotation()
            //filteredLocation.remove(at: indexPath.row)
        }
        //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //}
        tableView.reloadData()
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addLocationSegue" {
            let destination = segue.destination as! AddLocationViewController
            //destination.coredataController = coreDataController
            destination.mapDelegate = mapDelegate
            //destination.tableViewController = self
        }
    }
    

    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
