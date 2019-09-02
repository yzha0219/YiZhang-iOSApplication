//
//  MapViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 28/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func focusOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation,animated:true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate,latitudinalMeters: 1000,longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
