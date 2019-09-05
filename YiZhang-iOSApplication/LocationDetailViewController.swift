//
//  AnnotationDetailViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 31/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {

    var location: LocationAnnotation?
    var mapDelegate: MapDelegate?
    //let default_photo = ["Brighton_Beach_Boxes.png","Melbourne_Museum.png","Werribee Park and Mansion.png"]
    
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
//            if default_photo.contains(location!.photo!) {
            photo.image = UIImage(named: location!.photo!)
//            } else {
//                photo.image = loadImageData(fileName: location!.photo!)
//            }
            icon.image = UIImage(named: location!.icon!)
        }
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
