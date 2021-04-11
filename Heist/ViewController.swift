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
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        startHeistButton.setTitle("start", for: .normal)
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
           case .notDetermined:
              locationManager.requestWhenInUseAuthorization()
           return
           case .denied, .restricted:
              let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
              let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
              alert.addAction(okAction)
              present(alert, animated: true, completion: nil)
           return
           case .authorizedAlways, .authorizedWhenInUse:
            break
           default:
                print("YOU SHALL NOT PASS!!")

        }
    }
    
}

