//
//  MapViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 18/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController2: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeter: Double = 5000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServiceEnabled()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func centerLocation(_ sender: UIButton) {
        centerLocation()
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServiceEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else{
            displayMessage(title: "Alert", message: "Location Service Unavaliable")
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            displayMessage(title: "Restricted", message: "The authorization is restricted!")
            break
        case .denied:
            displayMessage(title: "Denied", message: "The authorization is denied! Please approve it in Setting!")
            break
        case .authorizedWhenInUse:
            centerLocation()
            locationManager.startUpdatingHeading()
            break
        @unknown default:
            break
        }
    }
    
    func centerLocation(){
        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D.init(latitude: -37.8136, longitude: 144.9631), latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
        mapView.setRegion(region, animated: true)
    }
    
    func displayMessage(title: String,message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //    guard let location = locations.last else { return }
    //    let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
    //    mapView.setRegion(region, animated: true)
    //}
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
