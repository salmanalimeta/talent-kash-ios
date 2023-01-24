//
//  CustomTabBarController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 13/09/2022.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import Firebase

class CustomTabBarController: UITabBarController,CLLocationManagerDelegate {
    private var selectedTabButton: UIButton!
    var videoId: String? = nil
    var childRef = Database.database().reference().child("ProviderLocation")
    var locationManager = CLLocationManager()
    required init?(coder:NSCoder) {
        super.init(coder: coder)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("RequestFromUser"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("notFromProvider"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("gotoChat"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("NEWMESSAGE"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("RELOAD"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.clipsToBounds = false
       setUpTabBarIcons()
        setNotifications()
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        }
        selectedTabButton = homeButton
        self.versionUpdate()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if videoId != nil{
            (selectedViewController as! HomeVideoViewController).fixedReels = true
//            ((selectedViewController as! UINavigationController).viewControllers.last as! HomeVideoViewController).openShareVideo(id)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let id = videoId{
            (selectedViewController as! HomeVideoViewController).openShareVideo(id)
            videoId = nil
        }
    }
    private func setUpTabBarIcons(){
        let container = UIView(frame: .init(origin: .zero, size: .init(width: UIScreen.main.bounds.width, height: 60)))
        let line = UIView()
        line.backgroundColor = UIColor(named: "separator")!
        line.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(line)
        container.addSubview(homeButton)
        container.addSubview(discoveryButton)
        container.addSubview(createButton)
        container.addSubview(chatButton)
        container.addSubview(profileButton)
        tabBar.addSubview(container)
        container.backgroundColor = UIColor(named: "secondaryColor")
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            container.topAnchor.constraint(equalTo: tabBar.topAnchor),
            container.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor),
            
            line.topAnchor.constraint(equalTo: container.topAnchor),
            line.leftAnchor.constraint(equalTo: container.leftAnchor),
            line.rightAnchor.constraint(equalTo: container.rightAnchor),
            line.widthAnchor.constraint(equalTo: container.widthAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
            homeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            homeButton.topAnchor.constraint(equalTo: container.topAnchor),
            homeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            homeButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2),
            
            discoveryButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor),
            discoveryButton.topAnchor.constraint(equalTo: container.topAnchor),
            discoveryButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            discoveryButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2),
            
            createButton.leadingAnchor.constraint(equalTo: discoveryButton.trailingAnchor),
            createButton.topAnchor.constraint(equalTo: container.topAnchor,constant: -14),
            createButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            createButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2),
            
            chatButton.leadingAnchor.constraint(equalTo: createButton.trailingAnchor),
            chatButton.topAnchor.constraint(equalTo: container.topAnchor),
            chatButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            chatButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2),
            
            profileButton.leadingAnchor.constraint(equalTo: chatButton.trailingAnchor),
            profileButton.topAnchor.constraint(equalTo: container.topAnchor),
            profileButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            profileButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            profileButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.2),
        ])
    }
    private lazy var homeButton:UIButton = {
        var button:UIButton
        if #available(iOS 15.0, *) {
            button = UIButton(configuration: UIButton.Configuration.plain())
            button.configuration?.imagePlacement = .top
        } else {
            button = UIButton()
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "homeActive"), for: .selected)
        button.setImage(UIImage(named: "home"), for: .normal)
        button.contentEdgeInsets = .init(top: 10, left: 0, bottom: 14, right: 0)
        button.setAttributedTitle(NSAttributedString(string: "Home",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor(named:"foreground")!]), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: "Home",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .bold),NSAttributedString.Key.foregroundColor:UIColor(named:"primary")!]), for: .selected)
        button.isSelected = true
        button.tintColor = UIColor.clear
        if #unavailable(iOS 15.0) {
            button.alignImageTop()
        }
        button.addTarget(self, action: #selector(homeButtonClick), for: .touchUpInside)
       return button
    }()
    private lazy var discoveryButton:UIButton = {
        var button:UIButton
        if #available(iOS 15.0, *) {
            button = UIButton(configuration: UIButton.Configuration.plain())
            button.configuration?.imagePlacement = .top
        } else {
            button = UIButton()
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "discoverActive"), for: .selected)
        button.setImage(UIImage(named: "discover"), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: "Discover",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor(named:"foreground")!]), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: "Discover",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11, weight: .bold),NSAttributedString.Key.foregroundColor:UIColor(named:"primary")!]), for: .selected)
        button.addTarget(self, action: #selector(discoveryButtonClick), for: .touchUpInside)
        button.tintColor = UIColor.clear
        if #unavailable(iOS 15.0) {
            button.alignImageTop()
        }
       return button
    }()
    private lazy var createButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "create"), for: .normal)
        button.addTarget(self, action: #selector(createButtonClick), for: .touchUpInside)
       return button
    }()
    private lazy var chatButton:UIButton = {
        var button:UIButton
        if #available(iOS 15.0, *) {
            button = UIButton(configuration: UIButton.Configuration.plain())
            button.configuration?.imagePlacement = .top
        } else {
            button = UIButton()
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "chatActive"), for: .selected)
        button.setImage(UIImage(named: "chat"), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: "Chat",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor(named:"foreground")!]), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: "Chat",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .bold),NSAttributedString.Key.foregroundColor:UIColor(named:"primary")!]), for: .selected)
        button.tintColor = UIColor.clear
        if #unavailable(iOS 15.0) {
            button.alignImageTop()
        }
        button.addTarget(self, action: #selector(chatButtonClick), for: .touchUpInside)
       return button
    }()
    private lazy var profileButton:UIButton = {
        var button:UIButton
        if #available(iOS 15.0, *) {
            button = UIButton(configuration: UIButton.Configuration.plain())
            button.configuration?.imagePlacement = .top
        } else {
            button = UIButton()
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "profile"), for: .normal)
        button.setImage(UIImage(named: "profileActive"), for: .selected)
        button.setAttributedTitle(NSAttributedString(string: "Profile",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor(named:"foreground")!]), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: "Profile",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .bold),NSAttributedString.Key.foregroundColor:UIColor(named:"primary")!]), for: .selected)
        button.tintColor = UIColor.clear
        if #unavailable(iOS 15.0) {
            button.alignImageTop()
        }
        button.addTarget(self, action: #selector(profileButtonClick), for: .touchUpInside)
       return button
    }()
    
    @objc func homeButtonClick(sender:UIButton){
        selectedTabButton.isSelected = false
        sender.isSelected = true
        selectedTabButton = sender
        selectedIndex = 0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
//
//        UserDefaults.standard.set(userLocation.coordinate.latitude, forKey: "currentLat")
//        UserDefaults.standard.set(userLocation.coordinate.longitude, forKey: "currentLong")
        if UserDefaultManager.instance.userType == .talent{
            let coord = ["lat":"\(userLocation.coordinate.latitude)","long":"\(userLocation.coordinate.longitude)"] as [String : Any]
            self.childRef.child(UserDefaultManager.instance.userID).updateChildValues(coord)
        }
  
    }

    @objc func discoveryButtonClick(sender:UIButton){
        selectedTabButton.isSelected = false
        sender.isSelected = true
        selectedTabButton = sender
        selectedIndex = 1
    }
    @objc func createButtonClick(sennder:UIButton){
        if  UserDefaultManager.instance.userType == .guest{
            let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "LogInAlertVC") as! LogInAlertVC
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
        }else{
            let vc = UIStoryboard(name: "CreatingVideo", bundle: nil).instantiateViewController(withIdentifier: "actionMediaViewController") as! actionMediaViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
        }
    }
    @objc func chatButtonClick(sender:UIButton){
        if  UserDefaultManager.instance.userType == .guest{
            let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "LogInAlertVC") as! LogInAlertVC
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
        }else{
            selectedTabButton.isSelected = false
            sender.isSelected = true
            selectedTabButton = sender
            selectedIndex = 2
        }
    }
    @objc func profileButtonClick(sender:UIButton){
        if UserDefaultManager.instance.userType == .guest{
            let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "LogInAlertVC") as! LogInAlertVC
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
        }else{
            selectedTabButton.isSelected = false
            sender.isSelected = true
            selectedTabButton = sender
            selectedIndex = 3
        }
    }
    func deleteReel(reelId:String) {
        let vc = viewControllers?.first(where: { vc in
            vc is HomeVideoViewController
        })
        ( vc as! HomeVideoViewController).deleteReel(reelId:reelId)
    }
    private func setNotifications(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openInsuficientPopup),
                                               name: Notification.Name("RELOAD"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification),
                                               name: Notification.Name("RequestFromUser"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification1),
                                               name: Notification.Name("notFromProvider"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gotoChat),
                                               name: Notification.Name("gotoChat"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NEWMESSAGE),
                                               name: Notification.Name("NEWMESSAGE"),
                                               object: nil)
        
    }
    @objc private func openInsuficientPopup(notification: NSNotification){
        let alert = InsufficientRequestPopup(frame: .init(origin: .zero, size:view.frame.size))
        alert.onRecharchWalletClick = {
            let vc = UIStoryboard.init(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "CoinController") as! CoinController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc , animated: true)
        }
        view.addSubview(alert)
    }
    @objc func handleNotification(notification: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "AcceptProviderController") as! AcceptProviderController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
  
    @objc func gotoChat(notification: NSNotification) {
        selectedIndex = 2
        let vc = viewControllers?.first(where: { vc in
            vc is ChatViewController
        })
        (vc as? ChatViewController)?.openActivityTab = true
    }
    
    @objc func NEWMESSAGE(notification: NSNotification) {
        selectedIndex = 2
    }
    @objc func handleNotification1(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            if let service_price = dict["service_price"] as? Int , let service = dict["service"] as? String , let name = dict["name"] as? String,let initial_Price = dict["initial_price"] as? Int,let bookingId = dict["bookingId"] as? String,let image = dict["userImage"] as? String,let remaining_price = dict["remaining_price"] as? Int,let status = dict["status"] as? String,let userID = dict["userId"] as? String {
                if status == "accepted"{
                    let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
                    let vc = st.instantiateViewController(withIdentifier: "ConfirmConntroller") as! ConfirmConntroller
                    vc.name = name
                    vc.remainingPrice = "\(remaining_price)"
                    vc.initPrice = "\(initial_Price)"
                    vc.userImage = image
                    vc.bookingID = bookingId
                    vc.serviceName = service
                    vc.serPrice = "\(service_price)"
                    vc.userID = userID
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }else{
                    let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
                    let vc = st.instantiateViewController(withIdentifier: "DeclinedViewController") as! DeclinedViewController
                    vc.name = name
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
    }
   private func versionUpdate(){
        NetworkUtil.request(apiMethod: "https://itunes.apple.com/lookup?bundleId=com.soft.Talent-Cash", parameters:nil, requestType: .get, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            guard let data = data as? Data else {
                print("cast error")
                return
            }
            //            print(String(data: data, encoding: .utf8) ?? "")
            do{
                let value = try JSONDecoder().decode(VersionModel.self, from:  data)
                let apiVersion:String = value.results?[0].version ?? "1.0.0"
                let fullNameArr = apiVersion.components(separatedBy: ".")
                let surname = fullNameArr[2]
                let version:String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                let fullNameArr1 = version.components(separatedBy: ".")
                let surname1 = fullNameArr1[2]
                let myDouble = Double(surname)
                let myDouble2 = Double(surname1)
                if myDouble ?? 1.0 > myDouble2 ?? 1.0{
                    
                    let alertController = UIAlertController(title:nil, message: "A new version of this app is available,Please update to version "+apiVersion, preferredStyle: .alert)
                    
                    // Create the actions
                    let updateAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        
                        let appUrl = "https://apps.apple.com/app/\(Bundle.main.bundleIdentifier.unsafelyUnwrapped)/id6443825045"
                        if let url = URL(string: appUrl),
                           UIApplication.shared.canOpenURL(url){
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }
                    let cancelAction = UIAlertAction(title: "Skip this Version", style: UIAlertAction.Style.cancel) {
                        UIAlertAction in
                        NSLog("Cancel Pressed")
                    }
                    
                    // Add the actions
                    alertController.addAction(updateAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                }
                
                
            } catch {
                print("error: ", error)
            }
        }) { _,error in
            //            self.showToast(message: error)
        }
    }
}
