//
//  EditLocationViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 5/9/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class EditLocationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var location: LocationAnnotation?
    weak var databaseController: DatabaseProtocol?
    var mapDelegate: MapDelegate?
    var detailDelegate: DetailDelegate?
    var managedObjectContext: NSManagedObjectContext?
    var newLocation: CLLocationCoordinate2D?
    let dataSource = ["beach","church","government","handcuffs","mansion","museum","park","pier","ship","theatre","train-station","train","tree"]
    var icon: String = ""

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var iconPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if location != nil {
            nameLabel.text = location!.title
            descTextView.text = location!.desc
            addressTextField.text = location!.address
            //            if default_photo.contains(location!.photo!) {
            photo.image = UIImage(named: location!.photo!)
            icon = location!.icon!
        }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate!.databaseController
        managedObjectContext = appDelegate?.persistentContainer.viewContext
        iconPicker.dataSource = self
        iconPicker.delegate = self
        descTextView.delegate = self
        addressTextField.delegate = self
    }
    
    //Close the keyboard when user press return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Close the keyboard when user touch blank area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Save photo to the phote
    func savePhoto(photeImage: UIImage) -> String {
        guard let photeImage = photo.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return ""
        }
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = photeImage.jpegData(compressionQuality: 0.8)!
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data,attributes: nil)
            //let location = NSEntityDescription.insertNewObject(forEntityName:"Location", into: managedObjectContext!) as! Location
            //location.photo = "\(date)"
            do {
                try //self.managedObjectContext?.save()
                    displayMessage("Image has been saved!", "Success!")
                return filePath
            } catch {
                displayMessage("Could not save to database", "Error")
                return ""
            }
        }
        return ""
    }
    
    //Display the photo user picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            photo.image = pickedImage
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //Display the alert to ask the user whether they want to take the phote from photo library or camera
            let alert = UIAlertController(title: "Photo Source", message: "Choose where you want to get the phote.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default){(action: UIAlertAction!) in
                controller.sourceType = .camera
                self.present(controller, animated: true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default){(action: UIAlertAction!) in
                controller.sourceType = .photoLibrary
                self.present(controller, animated: true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    //Get the latitude and longtitude by the address
    func getLocation(address:String) {
        let geoCoder:CLGeocoder = CLGeocoder()
        geoCoder.geocodeAddressString(address, completionHandler: {(placemarks,error) -> Void in
            guard
                let placemark = placemarks?.first,
                let location = placemark.location
                else{
                    return
            }
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            self.newLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.icon = dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
    @IBAction func saveEdit(_ sender: Any) {
        let name = nameLabel.text
        let desc = descTextView.text
        //Add validation of users' iuput
        if desc == "" {
            displayMessage("Please enter description!", "Description is empty!")
            return
        }
        let address = addressTextField.text
        if address == "" {
            displayMessage("Please enter location!", "Location is empty!")
            return
        }
        getLocation(address: address!)
        //Wait 2 seconds for the completition of running geoLocation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            if self.newLocation == nil {
                self.displayMessage("Please enter a valid location!", "Location is invalid! We can't find the input address on the map!")
                return
            }
            let photoImage = self.photo.image
            let photo = self.savePhoto(photeImage: photoImage!)
            let icon = self.icon + ".png"
            self.databaseController?.updateLocation(name: name!, desc: desc!, address: address!, photo: photo, icon: icon, lat: self.newLocation!.latitude, long: self.newLocation!.longitude)
            self.mapDelegate!.reloadAnnotation()
            self.detailDelegate!.refreshLocation(name: name!, desc: desc!, address: address!, photo: photo, icon: icon)
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
    
    //Display the alert with customized information.
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
        
}
