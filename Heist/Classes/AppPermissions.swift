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
    
    // location
    class func askLocationPermission() -> Void {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    class func canAccessUserLocation() -> Bool {
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
           case .notDetermined:
            self.askLocationPermission()
            return false
           case .denied, .restricted:
            return false
           case .authorizedAlways, .authorizedWhenInUse:
            return true
           default:
                print("Unknown user location access status")
        }
            
        return false
    }
    
    // contacts
    class func askContactsPermissions() -> Void {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
        }
    }
    
    class func canAccessUserContacts() -> Bool {
      return false
    }
}
