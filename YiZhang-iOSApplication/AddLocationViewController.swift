//
//  AddLocationViewController.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 3/9/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import CoreData

class AddLocationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistentContainer.viewContext
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
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
    
    @IBAction func savePhoto(_ sender: Any) {
        guard let image = photo.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data,attributes: nil)
            let location = NSEntityDescription.insertNewObject(forEntityName:"Location", into: managedObjectContext!) as! Location
            location.photo = "\(date)"
            do {
                try self.managedObjectContext?.save()
                displayMessage("Image has been saved!", "Success!")
            } catch {
                displayMessage("Could not save to database", "Error")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            photo.image = pickedImage
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func takeIcon(_ sender: Any) {
        
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

}
