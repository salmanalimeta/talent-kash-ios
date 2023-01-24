//
//  HireMeController.swift
//  Talent Cash
//
//  Created by Aamir on 19/09/2022.
//

import UIKit
import CoreLocation
import Alamofire

class HireMeController: StatusBarController,CLLocationManagerDelegate {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    var reel:Reel?
    var sPrice:Int?
    var iPrice:Int?
    var rPrice:Int?
    var lat:Double?
    var long:Double?
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var initialPrice: UILabel!
    
    @IBOutlet weak var remPrice: UILabel!
    
    @IBOutlet weak var locLbl: UILabel!
    var locationManager = CLLocationManager()
    
    
    private var isLoading = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        descriptionTextView.layer.borderColor = UIColor(named:"grayBorderColor")?.cgColor ?? UIColor.systemGray.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        usernameLabel.text = reel?.user.username
        nameLabel.text = reel?.user.name
        profileImage.sd_setImage(with: URL(string: reel?.user.profileImage ?? ""),placeholderImage: UIImage(named: "placeholder.user"))
        
        self.priceLbl.text = "\(sPrice ?? 0) PKR"
        self.initialPrice.text = "\(iPrice ?? 0) PKR"
        self.remPrice.text = "\(rPrice ?? 0) PKR"
        // self.locLbl.text = reel?.location
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        
        
    }
    @IBAction func backButtonClack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func sendRequestButtonClick(_ sender: ButtonGradientBackground) {
        //         _ = showAlert(storyBoardID: "InsufficientBalanceCotroller")
        if isLoading{
            return
        }
        isLoading = true
        let parameters = ["userId":(UserDefaultManager.instance.userID),"reelId":reel?._id ?? 0,"description":self.descriptionTextView.text ?? ""] as [String : Any]
        
        print(parameters)
        self.startPulseAnimation()
        NetworkUtil.request(dataType:OTPModel.self,apiMethod: Constants.URL.sendRequest ,parameters: parameters , requestType: .post, onSuccess: {available in
            self.isLoading = false
            self.stopPulseAnimation()
            if available.status == true{
                let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
                let vc = st.instantiateViewController(withIdentifier: "AcceptWaitingController") as! AcceptWaitingController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }else{
                if available.message == " Your balance is low for this offer. Please recharge first !"{
                    let vc = (self.getAlert(storyBoardID: "InsufficientBalanceCotroller") as! InsufficientBalanceCotroller)
                    
                    self.present(vc, animated: true)
                }else{
                    let vc = (self.getAlert(storyBoardID: "ServiceUnavailableController") as! ServiceUnavailableController)
                    self.present(vc, animated: true)
                }
            }
        }) { _,error in
            self.stopPulseAnimation()
            print("error--",error)
            self.showToast(message: error)
        }
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        UserDefaults.standard.set(lat, forKey: "reelLat")
        UserDefaults.standard.set(long, forKey: "reelLong")
        UserDefaults.standard.set(userLocation.coordinate.latitude, forKey: "currentLat")
        UserDefaults.standard.set(userLocation.coordinate.longitude, forKey: "currentLong")
        let location = CLLocation(latitude:self.lat ?? 0.0  , longitude: self.long ?? 0.0)
        let distanceInMeters = location.distance(from: userLocation)
        var distance = distanceInMeters / 1000
        distance  =  distance.rounded(toPlaces: 3)
        self.locLbl.text = "\(distance) KM"
       // self.locationManager.stopUpdatingLocation()
        
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

