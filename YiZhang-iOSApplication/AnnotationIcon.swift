//
//  AnnotationIcon.swift
//  YiZhang-iOSApplication
//
//  Created by Yi Zhang on 6/9/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import MapKit

class AnnotationIcon: MKAnnotationView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //Customiza the icon of each annotation on the map
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? LocationAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            let iconButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
            if UIImage(named: annotation.title!) != nil
            {
                iconButton.setBackgroundImage(UIImage(named: annotation.title!), for: UIControl.State())
            }else if let iconData = UserDefaults.standard.object(forKey: (annotation.title!))
            {
                iconButton.setBackgroundImage(UIImage(data: iconData as! Data), for: UIControl.State())
            }
            leftCalloutAccessoryView = iconButton
            
            if let iconName = annotation.icon {
                image = UIImage(named: iconName)
            } else {
                image = nil
            }
        }
    }

}
