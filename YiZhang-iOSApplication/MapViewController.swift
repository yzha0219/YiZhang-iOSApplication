//
//  MapViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 28/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, MapDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var allLocationViewController: AllLocationTableViewController?
    var allLocation: [Location] = []
    //var coreDataController: CoreDataController = CoreDataController()
    var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initialRegion()
        mapView.delegate = self
        //coreDataController = CoreDataController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        allLocation = databaseController!.fetchAllLocation()
//        for location in allLocation {
//            let title = location.name
//            let lat = location.latitude
//            let long = location.longtitude
//            let address = location.address
//            let desc = location.desc
//            let icon = location.icon
//            let photo = location.photo
//            let annotation = LocationAnnotation(title: title!,address: address!,desc: desc!,icon: icon!,photo: photo!,lat: lat,long: long)
//            mapView.addAnnotation(annotation)
//        }
        reloadAnnotation()
    }
    
    func focusOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation,animated:true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate,latitudinalMeters: 2000,longitudinalMeters: 2000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func removeAnnotation(annotation: MKAnnotation) {
        mapView.removeAnnotation(annotation)
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        mapView.addAnnotation(annotation)
    }
    
    func reloadAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
        allLocation = databaseController!.fetchAllLocation()
        print(allLocation.count)
        for location in allLocation {
            let title = location.name
            let lat = location.latitude
            let long = location.longtitude
            let address = location.address
            let desc = location.desc
            let icon = location.icon
            let photo = location.photo
            let annotation = LocationAnnotation(title: title!,address: address!,desc: desc!,icon: icon!,photo: photo!,lat: lat,long: long)
            mapView.addAnnotation(annotation)
        }
    }
    
    func initialRegion(){
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: -37.8136, longitude: 144.9631),latitudinalMeters: 2000,longitudinalMeters: 2000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.performSegue(withIdentifier: "LocationDetailSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LocationDetailSegue" {
            let destination = segue.destination as! LocationDetailViewController
            destination.location = mapView.selectedAnnotations[0] as? LocationAnnotation
            destination.mapDelegate = self
        }
        if segue.identifier == "AllLocationSegue" {
            let destination = segue.destination as! AllLocationTableViewController
            destination.mapDelegate = self
            destination.mapViewController = self
        }
    }

}
