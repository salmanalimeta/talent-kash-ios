//
//  postViewController.swift
//  TIK TIK
//
//  Created by Mac on 28/08/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import Photos
import CoreLocation
import GooglePlaces
import LightCompressor

class postViewController: StatusBarController,UITextViewDelegate,CLLocationManagerDelegate {
 
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var privacyIconImg: UIImageView!
    @IBOutlet weak var vidThumbnail: UIImageView!
    @IBOutlet weak var describeTextView: UITextView!
    var locationManager = CLLocationManager()
    private var compression: Compression? = nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var priceView: UIView!
    
    @IBOutlet weak var serviceView: UIView!
    
    @IBOutlet weak var txtCat: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    private var videoDownloader:VideoDownloader? = nil
    
    var videoUrl:URL!
    var SpeedValue:Float = 1.0
    var privacyType = "Public"
    var desc = ""
    var allowDuet = "1"
    var allowComments = "true"
    var duet = "1"
    var soundId = "null"
    var saveV = "1"
    var locLat = "0.0"
    var locLong = "0.0"
    
    var isService:String = "0"
    
    var boxView = UIView()
    var blurView = UIView()
    
    var hashTagsArr = [String]()
    var userTagsArr = [String]()
    
    private var isBusy = false
    override func viewDidLoad() {
        super.viewDidLoad()
        describeTextView.text = "/* Add caption with hashtags and mentions */"
        describeTextView.textColor = UIColor.lightGray
        
        let privayOpt = UITapGestureRecognizer(target: self, action:  #selector(self.privacyOptionsList))
        self.privacyView.addGestureRecognizer(privayOpt)
        self.getThumbnailImageFromVideoUrl(url: videoUrl) { (thumb) in
            self.vidThumbnail.image = thumb
        }
        
        describeTextView.layer.borderColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0).cgColor
        describeTextView.layer.borderWidth = 1.0
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0.1
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        
        self.txtPrice.placeholderColor(color: UIColor.gray)
        self.txtCat.placeholderColor(color: UIColor.gray)
        
        if UserDefaultManager.instance.userType == .talent{
            self.serviceView.alpha = 1
        }else{
            self.serviceView.alpha = 0
        }
//        let attribute = try! FileManager.default.attributesOfItem(atPath:videoUrl.path)
//        if let size = attribute[FileAttributeKey.size] as? NSNumber {
//            let sizeInMB = size.doubleValue / 1000000.0
//            print("uplaod before sizeInMB=",sizeInMB)
//        }
    }
    
    
    @IBAction func serviceSelect(_ sender: Any) {
        let actionSheetAlertController: UIAlertController = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        print(Constants.servicesArray.count)
        for title in Constants.servicesArray {
            let action = UIAlertAction(title: title.service_name, style: .default) { (action) in
                print("Title: \(title)")
                self.txtCat.text = title.service_name
            }
            actionSheetAlertController.addAction(action)
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelActionButton)
        self.present(actionSheetAlertController, animated: true, completion: nil)
    }
    
    
    
    
    
    @IBAction func selectLocation(_ sender: Any) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
            textView.text = .none
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "/* Add caption with hashtags and mentions */"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func serviceChange(_ sender: UISwitch) {
        if sender.isOn {
            self.isService = "1"
            self.priceView.alpha = 1
        }else{
            self.isService = "0"
            self.priceView.alpha = 0
        }
    }
    
    //    func textViewDidChange(_ textView: UITextView) {
    //        describeTextView.setText(text: describeTextView.text,textColor: .white, withHashtagColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), andMentionColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), andCallBack: { (strng, type) in
    //            print("type: ",type)
    //            print("strng: ",strng)
    //
    //
    //        }, normalFont: .systemFont(ofSize: 14, weight: UIFont.Weight.light), hashTagFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold), mentionFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold))
    //    }
    
    func uploadData(_ videoUrl:URL){
        
        //        let hashtags = describeTextView.text.hashtags()
        //        let mentions = describeTextView.text.mentions()
        //
        //        var newHashtags = [[String:String]]()
        //        var newMentions = [[String:String]]()
        //
        //        for hash in hashtags{
        //            newHashtags.append(["name":hash])
        //        }
        //        for mention in mentions{
        //            newMentions.append(["name":mention])
        //        }
        //
        //AppUtility?.startLoader(view: self.view)
        //        //        let  sv = HomeViewController.displaySpinner(onView: self.view)
        //        if(UserDefaults.standard.string(forKey: "sid") == nil || UserDefaults.standard.string(forKey: "sid") == ""){
        //
        //            UserDefaults.standard.set("null", forKey: "sid")
        //        }
        //
        //  let url : String = self.appDelegate.baseUrl!+self.appDelegate.uploadMultipartVideo!
        let url : String = Constants.URL.postVideo
        //
        //        let cmnt = self.allowComments
        //        let allwDuet = self.allowDuet
        //        let prv = self.privacyType
        //        if describeTextView.text != "Describe your video" {
        //            des = describeTextView.text
        //        }else{
        //            des = ""
        //        }
        //
        //        print("cmnt",cmnt)
        //        print("allwDuet",allwDuet)
        //        print("prv",prv)
        //        print("des",des)
        //        print("hashtags",hashtags)
        //        print("mentions",mentions)
        
        var user_id = UserDefaultManager.instance.user?._id ?? "631b2ae3da9dd6dc5907adf4"
        var song_id = ""
        if UserDefaults.standard.string(forKey: "selecedSongID") != nil{
            song_id = UserDefaults.standard.string(forKey: "selecedSongID") ?? ""
        }else{
            song_id = ""
        }
        var descriptionData:String = ""
        
        if self.describeTextView.text == "/* Add caption with hashtags and mentions */"{
            descriptionData = ""
        }else{
            descriptionData = self.describeTextView.text
        }
        var parameter :[String:Any]? = ["":""]
        
        if isService == "1"{
            
            parameter =  ["userId"       : user_id,
                          "songId"      : song_id,
                          "hashtag"   : "",
                          "mentionPeople"   : "",
                          "caption"   :  descriptionData,
                          "isService":self.isService,
                          "service_price":self.txtPrice.text ?? "",
                          "service":self.txtCat.text ?? "",
                          "lat":self.locLat,
                          "long":self.locLong,
                          "speed":self.SpeedValue
            ]
        }else{
            parameter =  ["userId"       : user_id,
                          "songId"      : song_id,
                          "hashtag"   : "",
                          "mentionPeople"   : "",
                          "caption"   :  descriptionData,
                          "lat":self.locLat,
                          "long":self.locLong,
                          "speed":self.SpeedValue
            ]
        }
        // let uidString = UserDefaults.standard.string(forKey: "userID")!
        // let soundIDString = "null"
        
        print(url)
        print(parameter!)
        let headers: HTTPHeaders = [
            "key":"soft@12345"
        ]
        _ = DataResponseSerializer(emptyResponseCodes: Set([200, 204, 205]))
        AF.upload(multipartFormData: { MultipartFormData in
            if (!JSONSerialization.isValidJSONObject(parameter ?? ["":""])) {
                print("is not a valid json object")
                return
            }
            for key in parameter!.keys{
                let name = String(key)
                print("key",name)
                if let val = parameter![name] as? String{
                    MultipartFormData.append(val.data(using: .utf8)!, withName: name)
                }
            }
            print(videoUrl)
            //                   let converter = VideoConverter()
            //                   converter.delegate = self
            //                   converter.videoOutputSize = .video
            //                   converter.videoOutputBitRate = .bitRate25
            //
            //                   //Send asset or url path of the video
            //                // converter.compressVideo(asset: AVAsset)
            //                   converter.compressVideo(videoUrl: self.videoUrl!)
            MultipartFormData.append(videoUrl, withName: "video")
            
            
            guard let imgData = self.vidThumbnail.image?.jpegData(compressionQuality: 0.25) else { return }
            
            guard let imgData2 = self.vidThumbnail.image?.jpegData(compressionQuality: 0.25) else { return }
            
            MultipartFormData.append(imgData, withName: "thumbnail", fileName: "thumbnail.jpeg", mimeType: "image/jpeg")
            MultipartFormData.append(imgData, withName: "screenshot", fileName: "screenshot.jpeg", mimeType: "image/jpeg")
            MultipartFormData.append(imgData2, withName: "productImage", fileName: "productImage.jpeg", mimeType: "image/jpeg")
        }, to: url, method: .post, headers: headers)
        .responseJSON { (response) in
            switch response.result{
            case .success(let value):
                self.stopPulseAnimation()
                self.isBusy = false
                let json = value
                let dic = json as! NSDictionary
                print("response:- ",response)
                
                
                if(dic["status"] as! Bool == true){
                    debugPrint("SUCCESS RESPONSE: \(response)")
                    print("Dict: ",dic)
                    UserDefaults.standard.set("yes", forKey: "uploaded")
                    self.goToHomeScene()
                }
               
            case .failure(let error):
                self.isBusy = false
                self.stopPulseAnimation()
                self.showToast(message:error.localizedDescription, font:UIFont.systemFont(ofSize: 14.0))
                print("Error Messsage: \(error.localizedDescription)")
                
            }
        }
    }

    
    
    
    @IBAction func btnPost(_ sender: Any) {
        if isBusy {
            return
        }
        self.isBusy = true
        if isService == "1"{
            if txtCat.text?.isEmpty == true {
                self.showToast(message:"Please select service category.", font: UIFont.systemFont(ofSize: 12.0))
                return
            }
            if txtPrice.text?.isEmpty == true {
                self.showToast(message:"Please enter service price.", font: UIFont.systemFont(ofSize: 12.0))
                return
            }
        }
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed.mp4")
        try? FileManager.default.removeItem(at: destinationPath)
        
        compression = LightCompressor().compressVideo(source: self.videoUrl,
                                                      destination: destinationPath as URL,
                                                      quality: .medium,
                                                      isMinBitRateEnabled: true,
                                                      keepOriginalResolution: false,
                                                      progressQueue: .main,
                                                      progressHandler: { progress in
            print("\(String(format: "%.0f", progress.fractionCompleted * 100))%")
        },
                                                      
                                                      completion: {[weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .onSuccess(let path):
//                let attribute = try! FileManager.default.attributesOfItem(atPath:path.path)
//                if let size = attribute[FileAttributeKey.size] as? NSNumber {
//                    let sizeInMB = size.doubleValue / 1000000.0
//                    print("uplaod after sizeInMB=",sizeInMB)
//                }
                DispatchQueue.main.async { [unowned self] in
                    self.uploadData(path)
                    if self.videoDownloader == nil{
                        self.videoDownloader = VideoDownloader(self)
                    }
                    self.videoDownloader?.download(url: path)
                }
            case .onStart:
                self.startPulseAnimation()
                //self.originalSize.visiblity(gone: false)
                
            case .onFailure(let error):
                if error.title == "The provided bitrate is smaller than what is needed for compression try to set isMinBitRateEnabled to false"{
                    DispatchQueue.main.async { [unowned self] in
                        self.uploadData(self.videoUrl)
                    }
                }else{
                    self.showToast(message: error.title)
                    self.isBusy = false
                }
            case .onCancelled:
                self.isBusy = false
                print("---------------------------")
                print("Cancelled")
                print("---------------------------")
            }
        })
    }
    @IBAction func commentSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.allowComments = "true"
        }else{
            self.allowComments = "false"
        }
    }
    
    @IBAction func duetSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.allowDuet = "1"
        }else{
            self.allowDuet = "0"
        }
    }
    
    @IBAction func saveSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.saveV = "1"
        }else{
            self.saveV = "0"
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        print("pressed")
    }
    
    //    MARK:- ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    //    MARK:- UIVIEWS ACTIONS
    @objc func privacyOptionsList(sender : UITapGestureRecognizer) {
        //        let vc = self.storyboard?.instantiateViewController(withIdentifier: "privacyVC") as! privacyViewController
        //        vc.modalPresentationStyle = .fullScreen
        //        present(vc, animated: true, completion: nil)
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let Public: UIAlertAction = UIAlertAction(title: "Public", style: .default) { action -> Void in
            
            self.privacyType = "Public"
            self.publicLabel.text = "Public"
            
        }
        
        let Friends: UIAlertAction = UIAlertAction(title: "Friends", style: .default) { action -> Void in
            
            self.privacyType = "Friends"
            self.publicLabel.text = "Friends"
            
        }
        
        let Private: UIAlertAction = UIAlertAction(title: "Private", style: .default) { action -> Void in
            self.privacyType = "Private"
            self.publicLabel.text = "Private"
            
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        actionSheetController.addAction(Public)
        actionSheetController.addAction(Friends)
        actionSheetController.addAction(Private)
        actionSheetController.addAction(cancelAction)
        
        
        // present an actionSheet...
        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad
        
        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad
        
        present(actionSheetController, animated: true) {
            print("option menu presented")
        }
        
    }
    
    //    MARK:- CHANEGE PRIVACY INFO
    
    
    
    
    //    MARK:- SET VIDEO THUMBNAIL FUNC
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbNailImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    //    MARK:- SAVE VIDEO DATA
    
    func requestAuthorization(completion: @escaping ()->Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized{
            completion()
        }
    }
    
    func showShimmer(progress: String){
        
        //        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 70, width: 180, height: 50))
        boxView.backgroundColor = UIColor.white
        boxView.alpha = 0.8
        boxView.layer.cornerRadius = 10
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.gray
        textLabel.text = progress
        
        blurView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        let blurView = UIView(frame: UIScreen.main.bounds)
        
        
        boxView.addSubview(blurView)
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
    }
    
    func HideShimmer(){
        boxView.removeFromSuperview()
    }
    
    
    //    MARK:- BTN HASHTAG AND MENTIONS SETUPS
    @IBAction func btnHashtag(_ sender: UISwitch) {
        
        //        guard self.describeTextView.text != "/* Add caption with hashtags and mentions */" else {return}
        //
        //        self.describeTextView.setText(text: describeTextView.text+" #",textColor: .black, withHashtagColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), andMentionColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), andCallBack: { (strng, type) in
        //            print("type: ",type)
        //            print("strng: ",strng)
        //        }, normalFont: .systemFont(ofSize: 14, weight: UIFont.Weight.light), hashTagFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold), mentionFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold))
        
    }
    
    @IBAction func btnMention(_ sender: UISwitch) {
        
        //        guard self.describeTextView.text != "/* Add caption with hashtags and mentions */" else {return}
        //
        //        self.describeTextView.setText(text: describeTextView.text+" @",textColor: .black, withHashtagColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), andMentionColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), andCallBack: { (strng, type) in
        //            print("type: ",type)
        //            print("strng: ",strng)
        //        }, normalFont: .systemFont(ofSize: 14, weight: UIFont.Weight.light), hashTagFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold), mentionFont: .systemFont(ofSize: 14, weight: UIFont.Weight.bold))
        
    }
    
    func dictToJSON(dict:[String: AnyObject]) -> AnyObject {
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        return jsonData as AnyObject
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        //print("locations = \(userLocation.) \(userLocation.longitude)")
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.locLat =  "\(locValue.latitude)"
        self.locLong =  "\(locValue.longitude)"
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let pm = placemarks![0]
                //                                      print(pm.country)
                //                                      print(pm.locality)
                //                                      print(pm.subLocality)
                //                                      print(pm.thoroughfare)
                //                                      print(pm.postalCode)
                //                                      print(pm.subThoroughfare)
                var addressString : String = ""
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                }
                
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                }
                if pm.country != nil {
                    addressString = addressString + pm.country! + ", "
                }
                
                
                
                print(addressString)
                
                self.locationLabel.text = addressString
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                vc.showToast(message: "Video uploaded successfully!")
            })
        }
        AppAnalytic.shared.postAnalyticsEvent(event: .VideoPost)
        AppAnalytic.shared.postAnalyticsEventOnFB(event: .VideoPost)
    }
}

extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }
        
        return String(data: theJSONData, encoding: .ascii)
    }
}
extension postViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //    print("Place name: \(place.name)")
        //    print("Place ID: \(place.placeID)")
        //    print("Place attributions: \(place.attributions)")
        self.startPulseAnimation()
        self.locationLabel.text = place.name
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(place.name ?? "") { placemarks, error in
            self.stopPulseAnimation()
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            print("Lat: \(lat ?? 0.0), Lon: \(lon ?? 0.0)")
            
            self.locLat = "\(lat ?? 0.0)"
            self.locLong = "\(lon ?? 0.0)"
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
extension UITextField {
    func placeholderColor(color: UIColor) {
        let attributeString = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: self.font!
        ] as [NSAttributedString.Key : Any]
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: attributeString)
    }
}
extension postViewController:VideoDownloaderDelegagte{
    func videoDownloadStarted() {
       // videoDownloadBar.isHidden = false
    }
    
    func videoDownloadProgress(progress: Int) {
        //videoDownloadProgress.text = " \(progress)% downloaded"
        print(progress)
    }
    
    func videoDownloadCompleted() {
        //videoDownloadBar.isHidden = true
        self.showToast(message: "Video Saved to Photos")
    }
    
    func videoDownloadBusy() {
        self.showToast(message: "Video already in progress, Try later!")
    }
    
    func videoDownloadFailed(msg: String) {
       // videoDownloadBar.isHidden = true
        self.showToast(message: msg)
    }
}

