//
//  trackController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 19/09/2022.
//

import UIKit
import GoogleMaps
import Alamofire
import MessageUI
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import Firebase
import SwiftyJSON
import CoreLocation

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
};extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class TrackController: StatusBarController,MFMessageComposeViewControllerDelegate,CLLocationManagerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == MessageComposeResult.cancelled{
            controller.dismiss(animated: true)
        }else if result == MessageComposeResult.sent{
        }else{
            controller.dismiss(animated: true)
        }
    }
    
    @IBOutlet weak var sheet: UIView!
    private var sheetOpened = false
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var oderNumber: UILabel!
    
    @IBOutlet weak var servAmount: UILabel!
    
    @IBOutlet weak var initPayment: UILabel!
    @IBOutlet weak var serviceName: UILabel!
    
    @IBOutlet weak var remainPayment: UILabel!
    
    private var providerPhone:String = "0"
    
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var customerName: UILabel!
    
    @IBOutlet weak var customerService: UILabel!
    
    @IBOutlet weak var customerImage: UIImageView!
    
    @IBOutlet weak var chatImage: UIImageView!
    
    @IBOutlet weak var callImage: UIImageView!
    
    @IBOutlet weak var mapView: GMSMapView!
    var polyArray = [GMSPolyline]()
    var riderMarker: GMSMarker!
    
    var name:String = ""
    var sPrice:String = ""
    var remainingPrice:String = ""
    var initPrice:String = ""
    var bookingID:String = ""
    var userImage:String = ""
    var otherId:String = "0"
    var serviceValue:String = ""
    var mapLat:Double = 0.0
    var mapLong:Double = 0.0
    var oldMapLat:Double = 0.0
    var oldMapLong:Double = 0.0
    var currentLat:Double = 0.0
    var currentLong:Double = 0.0

 
    @IBOutlet weak var btnArrow: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        safeAreaFooterCover.heightConstraint?.constant = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        self.providerPhone = UserDefaults.standard.string(forKey: "providerPhone") ?? "0000000"
        self.customerName.text = name
        self.servAmount.text = self.sPrice+" PKR"
        self.customerService.text = serviceValue
        self.serviceName.text = serviceValue
        self.remainPayment.text = self.remainingPrice+" PKR"
        self.initPayment.text = self.initPrice+" PKR"
        self.servAmount.text = self.sPrice+" PKR"
        let userImgUrl = URL(string: userImage)
        self.oderNumber.text = "ID-"+bookingID
        self.customerImage.sd_setImage(with: userImgUrl, placeholderImage: UIImage(named: "placeholder.user"))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        chatImage.isUserInteractionEnabled = true
        chatImage.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped1(tapGestureRecognizer:)))
        callImage.isUserInteractionEnabled = true
        callImage.addGestureRecognizer(tapGestureRecognizer1)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        
        
     
    }
    
    func getLocation(){
   
        let childRef = Database.database().reference().child("ProviderLocation").child(otherId)
        
        childRef.keepSynced(true)
        print(otherId)
        childRef.observe(.value, with: { (snapshot) in

                if !snapshot.exists() { return }

                print(snapshot) // Its print all values including Snap (User)

                print(snapshot.value!)
            let tempDIC = snapshot.value as? NSDictionary

            let lat  = tempDIC?["lat"] as? String
            let long = tempDIC?["long"] as? String
            self.mapLat = lat?.toDouble() ?? 0.0
            self.mapLong = long?.toDouble() ?? 0.0
            
            let oldCoodinate =  CLLocationCoordinate2D(latitude:self.oldMapLat, longitude:self.oldMapLong)
            let newCoodinate = CLLocationCoordinate2D(latitude:self.mapLat, longitude: self.mapLong)
                
//            self.riderMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
          self.riderMarker.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate, toCoordinate: newCoodinate))
//            //found bearing value by calculation when marker add
            self.riderMarker.position = oldCoodinate
//            //this can be old position to make car movement to new position
            self.riderMarker.map = self.mapView
//
            self.riderMarker.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate, toCoordinate: newCoodinate))
            self.getGooglePath()
            
            CATransaction.begin()
            CATransaction.setValue(Int(10), forKey: kCATransactionAnimationDuration)
            CATransaction.setCompletionBlock({(
                
                ) -> Void in
                
                self.riderMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
     
                
                //New bearing value from backend after car movement is done
                self.riderMarker.map = self.mapView
                self.riderMarker.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate, toCoordinate: newCoodinate))
                let location = CLLocationCoordinate2DMake(self.mapLat, self.mapLong)
                            
                self.riderMarker.position = location
                            //bounds.includingCoordinate(self.riderMarker.position)
                let camera = GMSCameraUpdate.setTarget(location)
               self.mapView.animate(with: camera)
            })
      
            //this can be new position after car moved from old position to new position with animation
           
//
            //found bearing value by calculation
            CATransaction.commit()

            


            self.oldMapLat = self.mapLat
            self.oldMapLong = self.mapLong

            })
        }
    
//    func getFirstLocation(){
//
//        let childRef = Database.database().reference().child("ProviderLocation").child(otherId)
//
//        childRef.keepSynced(true)
//        print(otherId)
//        childRef.observeSingleEvent(of: .value, with: { snapshot in
//
//                if !snapshot.exists() { return }
//
//                print(snapshot) // Its print all values including Snap (User)
//
//                print(snapshot.value!)
//            let tempDIC = snapshot.value as? NSDictionary
//
//            let lat  = tempDIC?["lat"] as? String
//            let long = tempDIC?["long"] as? String
//            self.mapLat = lat?.toDouble() ?? 0.0
//            self.mapLong = long?.toDouble() ?? 0.0
//
//
//            self.getGooglePath()
//            //let oldCoodinate =  CLLocationCoordinate2D(latitude:self.oldMapLat, longitude: self.oldMapLong)
//            let newCoodinate = CLLocationCoordinate2D(latitude:self.mapLat, longitude: self.mapLong)
//            self.mapView.animate(to: GMSCameraPosition.camera(withLatitude: self.mapLat, longitude: self.mapLong, zoom: 15))
//            let location = CLLocationCoordinate2DMake(self.mapLat, self.mapLong)
//
//            self.riderMarker.position = location
//                                                //bounds.includingCoordinate(self.riderMarker.position)
//            self.riderMarker.map = self.mapView
//            let camera = GMSCameraUpdate.setTarget(location)
//            self.mapView.animate(with: camera)
//
//            })
//        self.oldMapLat = self.mapLat
//        self.oldMapLat = self.oldMapLong
//        self.getLocation()
//
//        }

    
    func getGooglePath(){
 
        let sourceLocation = "\(currentLat),\(currentLong)"
        let destinationLocation = "\(mapLat),\(mapLong)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLocation)&destination=\(destinationLocation)&mode=driving&key=AIzaSyBexOgxBoQcQfml9tUAH73qljvAt2m41kg"
            
        print(urlString)

        AF.request(urlString).responseJSON { (responseObject) -> Void in
            
             let resJson = JSON(responseObject.value!)
            print(resJson)
            
            if(resJson["status"].rawString()! == "ZERO_RESULTS")
            {
                
            }
            else if(resJson["status"].rawString()! == "NOT_FOUND")
            {
                
            }
            else{
                
                if  let routes : NSArray = resJson["routes"].rawValue as? NSArray{
                    print(routes)
                    
                    //self.getAddressFromLatLon(pdblLatitude:StaticData.singleton.rider_lat!, withLongitude:StaticData.singleton.rider_lon!)
                    
                    for p in (0 ..< self.polyArray.count) {
                        (self.polyArray[p]).map = nil
                    }
                    let pathv : NSArray = routes.value(forKey: "overview_polyline") as! NSArray
                    print(pathv)
                    let paths : NSArray = pathv.value(forKey: "points") as! NSArray
                    print(paths)
                    let newPath = GMSPath.init(fromEncodedPath: paths[0] as! String)
                    
                    
                    let polyLine = GMSPolyline(path: newPath)
                    polyLine.strokeColor = UIColor(named: "primary") ?? UIColor.blue
                    polyLine.strokeWidth = 5
                   
                    self.polyArray.append(polyLine)
                    polyLine.map = self.mapView
                    self.polyArray.append(polyLine)
                    let bounds = GMSCoordinateBounds(path: newPath!)
                    //self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                }
                
            }
        }
        
    }
    
//    func getGooglePath(){
//
//        let sourceLocation = "\(currentLat),\(currentLong)"
//        let destinationLocation = "\(mapLat),\(mapLong)"
//
//        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLocation)&destination=\(destinationLocation)&mode=driving&key=AIzaSyBexOgxBoQcQfml9tUAH73qljvAt2m41kg"
//
//            let url = URL(string: urlString)
//            URLSession.shared.dataTask(with: url!, completionHandler: {
//                (data, response, error) in
//                if(error != nil){
//                    print("error")
//                }else{
//                    do{
//                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
//                        let routes = json["routes"] as! NSArray
//                        //self.mapView.clear()
//
//                        OperationQueue.main.addOperation({
//                            for route in routes
//                            {
//                                let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
//                                let points = routeOverviewPolyline.object(forKey: "points")
//                                let path = GMSPath.init(fromEncodedPath: points! as! String)
//                                let polyline = GMSPolyline.init(path: path)
//                                polyline.strokeWidth = 3
//                                polyline.strokeColor = UIColor(named: "primary").unsafelyUnwrapped
//
//                                let bounds = GMSCoordinateBounds(path: path!)
//                                self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 15.0))
//
//                                polyline.map = self.mapView
//                            }
//                        })
//                    }catch let error as NSError{
//                        print("error:\(error)")
//                    }
//                }
//            }).resume()
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        self.currentLat = userLocation.coordinate.latitude
        self.currentLong = userLocation.coordinate.longitude
       // self.currentLat =  UserDefaults.standard.double(forKey: "currentLat")
       // self.currentLong =  UserDefaults.standard.double(forKey: "currentLong")
        self.mapLat =  UserDefaults.standard.double(forKey: "reelLat")
        self.mapLong =  UserDefaults.standard.double(forKey: "reelLong")
        riderMarker = GMSMarker()
        
        let loc_coords = CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong)
       
        self.mapView.animate(to: GMSCameraPosition.camera(withLatitude: self.mapLat, longitude: self.mapLong, zoom: 15))
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong)
        //marker.title = "Your Location"
        marker.snippet = "Your Location"
        marker.icon = .init(named: "location.to")!
        marker.map = mapView
     
        riderMarker.position = CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong)
        riderMarker.snippet = name
        riderMarker.icon = .init(named:"location.from")!
        riderMarker.map = mapView
        
        
        self.getGooglePath()
        self.getLocation()
        self.locationManager.stopUpdatingLocation()

//        UserDefaults.standard.set(userLocation.coordinate.latitude, forKey: "currentLat")
//        UserDefaults.standard.set(userLocation.coordinate.longitude, forKey: "currentLong")
//        let coord = ["lat":"\(userLocation.coordinate.latitude)","long":"\(userLocation.coordinate.longitude)"] as [String : Any]
//        self.childRef.child(OtherID).updateChildValues(coord)
  
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        self.chatView.alpha = 1

        // Your action
    }
    
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        
        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        if degree >= 0 {
            return degree
        }
        else {
            return 360 + degree
        }
    }
    
    @IBAction func phoneMessage(_ sender: Any) {
        
        self.chatView.alpha = 0
        
        guard MFMessageComposeViewController.canSendText() else {
               print("Unable to send messages.")
               return
           }
           let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
        
        controller.recipients = [self.providerPhone]
           controller.body = ""
           present(controller, animated: true)
    }
    @objc func imageTapped1(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        if let url = URL(string: "tel://\(self.providerPhone)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
    }
    @IBAction func backClick(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func arrowDownClick(_ sender: UIButton) {
        
//        sheetOpened = !sheetOpened
//        UIView.animate(withDuration: 0.6, delay: 0) {
//            self.sheet.transform = self.sheetOpened ? CGAffineTransform.identity : CGAffineTransformMakeTranslation(0,self.sheet.frame.height*0.75)
//        }
//        UIView.animate(withDuration: 0.5, delay: 0) {
//            sender.transform = self.sheetOpened ? CGAffineTransform.identity : CGAffineTransformMakeRotation(180 * .pi / 180)
//        }
        
//        let screenSize: CGRect = UIScreen.main.bounds
        
        if sheetOpened == false{
            sheetOpened = true
            UIView.animate(withDuration: 0.6, delay: 0) {
                self.sheet.frame = CGRect(x: 0, y:self.sheet.frame.origin.y+90-self.sheet.frame.height , width:self.sheet.frame.width , height:self.sheet.frame.height)
                sender.transform = CGAffineTransformMakeRotation(-180 * .pi / 180)
            }
        }else{
            sheetOpened = false
            UIView.animate(withDuration: 0.6, delay: 0) {
                self.sheet.frame = CGRect(x: 0, y:self.sheet.frame.origin.y-90+self.sheet.frame.height, width:self.sheet.frame.width , height:self.sheet.frame.height)
                sender.transform = CGAffineTransform.identity
            }
        }
        
    }
    
    @IBAction func InAppChat(_ sender: Any) {
        self.chatView.alpha = 0
         let st:UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
         let vc = st.instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
         vc.modalPresentationStyle = .fullScreen
         vc.name = name
        vc.receiverId = self.otherId
         self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func Whatsapp(_ sender: Any) {
        self.chatView.alpha = 0
        let phoneNumber =  self.providerPhone // you need to change this number
        let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber )")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(appURL)
            }
        }
    }
}
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
