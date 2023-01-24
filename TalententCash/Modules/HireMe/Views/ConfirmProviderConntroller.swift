//
//  ConfirmProviderConntroller.swift
//  Talent Cash
//
//  Created by MacBook Pro on 30/09/2022.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import Firebase

class ConfirmProviderConntroller: StatusBarController,CLLocationManagerDelegate {
    
    @IBOutlet weak var orderID: UILabel!
    var bookeID:String = "0"
    var OtherID:String = "0"
    var locationManager = CLLocationManager()
    var childRef = Database.database().reference().child("ProviderLocation")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.orderID.text = "ID-"+bookeID
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.goToHomeScene() 
    }
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
                           vc.modalPresentationStyle = .fullScreen
                           self.present(vc, animated: true, completion: nil)
       
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
//
//        UserDefaults.standard.set(userLocation.coordinate.latitude, forKey: "currentLat")
//        UserDefaults.standard.set(userLocation.coordinate.longitude, forKey: "currentLong")
        let coord = ["lat":"\(userLocation.coordinate.latitude)","long":"\(userLocation.coordinate.longitude)"] as [String : Any]
        self.childRef.child(OtherID).updateChildValues(coord)
  
    }

}
