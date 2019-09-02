//
//  AnnotationDetailViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 31/8/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {

    var location: Location?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if location != nil {
            nameTextField.text = location!.name
            descTextView.text = location!.desc
            locationTextField.text = location!.address
            photo.image = UIImage(data: location!.photo! as Data)
            icon.image = UIImage(data: location!.icon! as Data)
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
    }
    
    @IBAction func takeIcon(_ sender: Any) {
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
