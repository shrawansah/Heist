//
//  ViewController.swift
//  Heist
//
//  Created by Shrawan Sah on 08/04/21.
//

import UIKit
import CoreLocation

struct heistedData {
    var Contacts: [FetchedContact]?
    var Location: [CLLocationDegrees?]?
}
var userData = heistedData()

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // UI elements
    @IBOutlet weak var startHeistButton: UIButton!
    
    // private vars
    private var appPermissions = AppPermissions()
    private var isLocationUpdated = false

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
        
        printUserData()
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
        
        userData.Contacts = appPermissions.getContacts()
    }
    
    private func showPermissionBlockedUI(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    // location manager deligates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        // this mrthod is triggered async, should make a separate api call
        let location = locations.last
        appPermissions.getLocationManager().stopUpdatingLocation()
        userData.Location = [location?.coordinate.latitude, location?.coordinate.longitude]
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Errors: " + error.localizedDescription)
    }
    
    func printUserData() {
        print(userData)
    }
}

