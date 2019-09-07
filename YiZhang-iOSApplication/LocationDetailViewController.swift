//
//  AnnotationDetailViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 31/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController, DetailDelegate {

    var location: LocationAnnotation?
    var mapDelegate: MapDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if location != nil {
            nameLabel.text = location!.title
            descTextView.text = location!.desc
            locationLabel.text = location!.address
            photo.image = UIImage(named: location!.photo!)
            icon.image = UIImage(named: location!.icon!)
        }
    }
    
    //Refresh the detail of location after update the content of core data
    func refreshLocation(name: String, desc: String, address: String, photo: String, icon: String) {
        nameLabel.text = name
        descTextView.text = desc
        locationLabel.text = address
        self.photo.image = UIImage(named: photo)
        self.icon.image = UIImage(named: icon)
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "editSightSegue" {
            let destination = segue.destination as! EditLocationViewController
            destination.location = location
            destination.mapDelegate = mapDelegate
            destination.detailDelegate = self
        }
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
