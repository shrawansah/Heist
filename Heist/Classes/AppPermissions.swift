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

struct FetchedContact {
    var firstName: String?
    var lastName: String?
    var telephone: String?
}

struct FetchedLocation {
    var longitude: String?
    var latitude: String?
}

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
        switch CNContactStore.authorizationStatus(for: .contacts) {
          case .notDetermined:
              return false
          case .authorized:
            return true
          case .denied:
            return false
          default: return false
          }
    }
    
    func getContactStore() -> CNContactStore {
        return contactsStore
    }
    
    func getContacts() -> [FetchedContact] {
        var contacts = [FetchedContact]()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try contactsStore.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
            })
        } catch let error {
            print("Failed to enumerate contact", error)
        }
        
        return contacts
    }
}
