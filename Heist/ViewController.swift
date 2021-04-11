//
//  ViewController.swift
//  Heist
//
//  Created by Shrawan Sah on 08/04/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var startHeistButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppPermissions.askLocationPermission();
        AppPermissions.askContactsPermissions();
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        // location
        if AppPermissions.canAccessUserLocation() {
            
        } else {
            let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        //contacts
        if AppPermissions.canAccessUserContacts() {
            
        } else {
            
        }
    }
    
}

