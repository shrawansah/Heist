//
//  AppPermissions.swift
//  Heist
//
//  Created by Shrawan Sah on 11/04/21.
//

import UIKit
import Foundation
import CoreLocation
import Contacts

class AppPermissions {
    private var locationManager: CLLocationManager
    private var contactsStore: CNContactStore
    
    init() {
        locationManager = CLLocationManager()
        contactsStore = CNContactStore()
    }
    
    // location
    func askLocationPermission() -> Void {
        if !canAccessUserLocation() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func canAccessUserLocation() -> Bool {
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
           case .notDetermined:
            return false
           case .denied, .restricted:
            return false
           case .authorizedAlways, .authorizedWhenInUse:
            return true
           @unknown default:
                print("Unknown user location access status")
        }
            
        return false
    }
    
    func getLocationManager() -> CLLocationManager {
        return locationManager
    }
    
    
    // contacts
    func askContactsPermissions() -> Void {
        if !canAccessUserContacts() {
            contactsStore.requestAccess(for: .contacts) { (granted, error) in
                if let error = error {
                    print("failed to request access", error)
                    return
                }
            }
        }
    }
    
    func canAccessUserContacts() -> Bool {
      return false
    }
}
