//
//  MapViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 28/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, MapDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var allLocationViewController: AllLocationTableViewController?
    var allLocation: [Location] = []
    var databaseController: DatabaseProtocol?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        self.initialRegion()
        mapView.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        allLocation = databaseController!.fetchAllLocation()
        reloadAnnotation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    
    //Create genfence
    func region(with annotation: LocationAnnotation) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: annotation.coordinate,
                                      radius: 100,
                                      identifier: annotation.title!)
        // 2
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    //Start monitoring whether the user enter into exit the geofence
    func startMonitoring(annotation: LocationAnnotation) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            displayMessage(title:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
             displayMessage(title:"Warning", message: message)
        }
        // 3
        let fenceRegion = region(with: annotation)
        // 4
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    //Stop monitoring
    func stopMonitoring(annotation: LocationAnnotation) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == annotation.title else {
                    continue
            }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    ////Listen to the action of enter into the geofence
    func locationManager(_ manager: CLLocationManager, didExitRegion region:
        CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have left \(region.identifier)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
            UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    ////Listen to the action of exit the geofence
    func locationManager(_ manager: CLLocationManager, didEnterRegion region:
        CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have entered into \(region.identifier)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
            UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Focus the map on a specific region
    func focusOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation,animated:true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate,latitudinalMeters: 1000,longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func removeAnnotation(annotation: MKAnnotation) {
        mapView.removeAnnotation(annotation)
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        mapView.addAnnotation(annotation)
    }
    
    //Draw geofence on the map view
    func addRadiusOverlay(forGeotification geofence: LocationAnnotation) {
        mapView?.addOverlay(MKCircle(center: geofence.coordinate, radius: geofence.radius!))
    }
    
    //Erase geofence on the map view
    func removeRadiusOverlay(forGeotification geofence: LocationAnnotation) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geofence.coordinate.latitude && coord.longitude == geofence.coordinate.longitude && circleOverlay.radius == geofence.radius {
                mapView?.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    //Customize the style of genfence
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 0.5
            circleRenderer.strokeColor = .red
            circleRenderer.fillColor = UIColor.cyan.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func reloadAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
        removeAnnotation(allLocation: allLocation)
        allLocation = databaseController!.fetchAllLocation()
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
            addRadiusOverlay(forGeotification: annotation)
            startMonitoring(annotation: annotation)
        }
        mapView.register(AnnotationIcon.self,forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    func removeAnnotation(allLocation: [Location]) {
        for location in allLocation {
            let title = location.name
            let lat = location.latitude
            let long = location.longtitude
            let address = location.address
            let desc = location.desc
            let icon = location.icon
            let photo = location.photo
            let annotation = LocationAnnotation(title: title!,address: address!,desc: desc!,icon: icon!,photo: photo!,lat: lat,long: long)
            removeRadiusOverlay(forGeotification: annotation)
            stopMonitoring(annotation: annotation)
            
        }
    }
    
    func initialRegion(){
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: -37.8136, longitude: 144.9631),latitudinalMeters: 3000,longitudinalMeters: 3000)
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
    
    //Display the alert with customized information.
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
