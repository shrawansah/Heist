//
//  ViewController.swift
//  Heist
//
//  Created by Shrawan Sah on 08/04/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // custom vars
    var userData = [
        "Contacts" : [],
        "Location" : [],
        "Calander" : [],
        "Reminders" : [],
    ] as [String : Any]
    
    // UI elements
    @IBOutlet weak var startHeistButton: UIButton!
    
    // private vars
    private var appPermissions = AppPermissions()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appPermissions.askLocationPermission();
        appPermissions.askContactsPermissions();
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        // location
        self.heistLocation()
        
        // contacts
        self.heistContacts()
        
    }
    
    private func heistLocation() {
        if !appPermissions.canAccessUserLocation() {
            showPermissionBlockedUI(title: "Location permission is disabled", message: "Please enable Location Services in your Settings")
            return
        }
        
        appPermissions.getLocationManager().delegate = self
        appPermissions.getLocationManager().startUpdatingLocation()

        
    }
    
    private func heistContacts() {
        if !appPermissions.canAccessUserContacts() {
            showPermissionBlockedUI(title: "Contacts permission is disabled", message: "Please enable contacts Services in your Settings")
            return
        }
        
        
    }
    
    private func showPermissionBlockedUI(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    // location manager deligates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last
        appPermissions.getLocationManager().stopUpdatingLocation()

        let locationData = [
            "Latitude" : location?.coordinate.latitude,
            "Longitude" : location?.coordinate.longitude
        ]
        
        userData["Location"] = locationData
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Errors: " + error.localizedDescription)
    }
}

