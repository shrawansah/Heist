//
//  ViewController.swift
//  Heist
//
//  Created by Shrawan Sah on 08/04/21.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    
    // UI elements
    @IBOutlet weak var startHeistButton: UIButton!
    @IBOutlet weak var userIdInput: UITextField!
    
    // private vars
    private var appPermissions = AppPermissions()
    private var isLocationUpdated = false
    private var userID = ""
    private var result = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) {
//            timer in
//                self.userIdInput.text = self.result
//            print("timer fired!  \(self.result)")
//
//        }
        
        
//        self.showToast(controller: self, message: self.result, seconds: 3)

    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)

        }
    }
    

    @IBAction func startButtonPressed(_ sender: UIButton) {
        return
        self.userID = userIdInput.text ?? ""
        let jsonTodo: Data

        do {
            var postData: [String: Any] = [:]
            postData["device_type"] = "ios_app"
            postData["is_api"] = true;
            
            jsonTodo = try JSONSerialization.data(withJSONObject: postData, options: [])
            saveUserData(jsonTodo: jsonTodo)
        } catch {
            print("Error: cannot create JSON from postData")
            return
        }
    }
    
    func saveUserData(jsonTodo: Data) {
        let todosEndpoint: String = "http://192.168.1.56:8082/v1/centers?pincode=110005"
        guard let todosURL = URL(string: todosEndpoint) else {
          print("Error: cannot create URL")
          return
        }
        var todosUrlRequest = URLRequest(url: todosURL)
        todosUrlRequest.httpMethod = "GET"

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
            
            let responseString = receivedTodo.description
            
            print(responseString)
            if responseString.contains(self.userID) {
                self.result = "Congrats!!"
            } else {
                self.result = "Nope!!"
            }
            print(self.result)

            
          } catch  {
            print("error parsing response from POST on /todos")
            return
          }
        }
        task.resume()
    }
}

