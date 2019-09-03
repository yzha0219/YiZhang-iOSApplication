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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
