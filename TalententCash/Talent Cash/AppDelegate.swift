//
//  AppDelegate.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 08/09/2022.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift
import GoogleSignIn
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GooglePlaces
import FirebaseMessaging
import UserNotifications
import Foundation
import GoogleMaps
import CoreData
import GSPlayer
import KochavaTracker
import CoreLocation

// this is vlc branch changes
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate,CLLocationManagerDelegate   {

    var window: UIWindow?
    var locationManager = CLLocationManager()
   // var timer = Timer()
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        KVATracker.shared.start(withAppGUIDString: "kotalent-cash-u89iwxp")
        showSignIn()
        DispatchQueue.global(qos: .userInitiated).async {
            self.getSongsList()
            self.getAllService()
        }
       
        GIDSignIn.sharedInstance().clientID = "24012201136-ejituisa5djpun2vp0co3js82f461kdh.apps.googleusercontent.com"
        
        GMSPlacesClient.provideAPIKey("AIzaSyAjcSIgnDKwqwyygeiKYW9bbLz-WFn7aT4")
        
        GMSServices.provideAPIKey("AIzaSyBF51mKrx1PGeadN2lQWCejbetWTNzupKA")
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                           categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FBSDKCoreKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        self.cleanUp()
        self.locationservices()
        return true
    }
    
    
    
    func locationservices(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let handled = FBSDKCoreKit.ApplicationDelegate.shared.application(app, open: url, options: options)
        
        return GIDSignIn.sharedInstance().handle(url)  || handled
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().token(completion: { token, error in
            
            if error == nil{
                print("InstanceID token: \(token ?? "")")
                UserDefaults.standard.set(token, forKey:"DeviceToken")
            }else{
                
                UserDefaults.standard.set("NuLL", forKey:"DeviceToken")
            }
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Registration failed!")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.locationservices()
        //timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        self.locationservices()
        }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.locationservices()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.locationservices()
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.locationservices()
        //self.timer.invalidate()
        DispatchQueue.global(qos: .background).async {
            if let lastDate  = UserDefaults.standard.object(forKey: "LAST_CACHE_DATE") as? Date{
                let start = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: lastDate)!
                let end = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                let days =  Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
                if days > 6{
                    try? VideoCacheManager.cleanAllCache()
                }
            }else{
                UserDefaults.standard.set(Date(), forKey: "LAST_CACHE_DATE")
            }
        }
    }
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
//        print("+_+_+_+_+_+_ OPEN IN userActivity METHOD _+_+++_+__+_+_+_+_+_+_+_+_+")
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let videoId = userActivity.webpageURL?.pathComponents.last{
               showSignIn(videoId)
            }
        }
        return false
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        
        let type  = userInfo[AnyHashable("type")] as? String
        
        if type == "TALL"{
            let jsonString  = userInfo[AnyHashable("data")] as? String
            do{
                
                let anyResult: Any = try JSONSerialization.jsonObject(with: (jsonString?.data(using: .utf8)!)!, options: [])
                let dic = anyResult as? [String: Any] ?? [:]
                
                

                NotificationCenter.default.post(name: Notification.Name("RequestFromUser"), object: dic)
                let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
//                let vc = st.instantiateViewController(withIdentifier: "AcceptProviderController") as! AcceptProviderController
                
//                vc.modalPresentationStyle = .fullScreen
//                UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
            }catch{
                
            }
        }
    }
    
    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
//        completionHandler([])
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground, received: \n \(notification.request.content)")
        print(notification.request.content.userInfo)
        
        let type:String  = notification.request.content.userInfo[AnyHashable("type")] as? String ?? ""
        if type == "TALL"{
            completionHandler([])
            let jsonString  = notification.request.content.userInfo[AnyHashable("data")] as? String ?? ""
            do{
                let anyResult: Any = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: [])
                let dic = anyResult as? [String: Any] ?? [:]
                NotificationCenter.default.post(name: Notification.Name("RequestFromUser"), object: dic)
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    NotificationCenter.default.post(name: Notification.Name("RequestFromUserData"), object: dic)
                }
            }catch{
                
            }
        } else if type == "SMALL"{
            
            completionHandler([])
            let jsonString  = notification.request.content.userInfo[AnyHashable("data")] as? String ?? ""
            do{
                
                let anyResult: Any = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: [])
                let dic = anyResult as? [String: Any] ?? [:]

                NotificationCenter.default.post(name: Notification.Name("notFromProvider"), object: dic)
                
            }catch{
            
            }
            
        }else if type == "NEWMESSAGE"{
            if #available(iOS 14.0, *) {
                completionHandler([.sound,.banner])
            } else {
                completionHandler([.sound,.alert])
            }
            let jsonString  = notification.request.content.userInfo[AnyHashable("data")] as? String ?? ""
            do{
                
                let anyResult: Any = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: [])
                let dict = anyResult as? [String: Any] ?? [:]
                
                if let senderId = dict["senderId"] as? String , let receiverId = dict["receiverId"] as? String
                    ,let sender_name = dict["sender_name"] as? String{
                    
                    Constants.notSenderID = senderId
                    Constants.notReceiverID = receiverId
                    Constants.notSenderName = sender_name
                    NotificationCenter.default.post(name: Notification.Name("NEWMESSAGE"), object: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        NotificationCenter.default.post(name: Notification.Name("NEWMESSAGE2"), object: nil)
                    }
                }
     
            }catch{
                
            }
        }else if type == "RELOAD"{
            NotificationCenter.default.post(name: Notification.Name(type), object: nil)
        }else {
            if #available(iOS 14.0, *) {
                completionHandler([.sound,.banner])
            } else {
                completionHandler([.sound,.alert])
            }
            NotificationCenter.default.post(name: Notification.Name("gotoChat"), object: nil)
        }
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle tapped push from background, received: \n \(response.notification.request.content)")
        
        let type  = response.notification.request.content.userInfo[AnyHashable("type")] as? String ?? ""
        //print(response.notification.request.content.userInfo[AnyHashable("data")])
        
        if type == "TALL"{
            let jsonString  = response.notification.request.content.userInfo[AnyHashable("data")] as? String ?? ""
            do{
                let anyResult: Any = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: [])
                let dic = anyResult as? [String: Any] ?? [:]
         
                NotificationCenter.default.post(name: Notification.Name("RequestFromUser"), object: dic)
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    NotificationCenter.default.post(name: Notification.Name("RequestFromUserData"), object: dic)
                }
            }catch{
                
            }
        }else if type == "SMALL"{
            
            let jsonString  = response.notification.request.content.userInfo[AnyHashable("data")] as? String ?? ""
            do{
                
                let anyResult: Any = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: [])
                let dic = anyResult as? [String: Any] ?? [:]
                

                NotificationCenter.default.post(name: Notification.Name("notFromProvider"), object: dic)
               
            }catch{
                 
            }
        }else if type == "NEWMESSAGE"{
            
            NotificationCenter.default.post(name: Notification.Name("NEWMESSAGE"), object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                NotificationCenter.default.post(name: Notification.Name("NEWMESSAGE2"), object: nil)
            }
                 
            }else if type == "RELOAD"{
                NotificationCenter.default.post(name: Notification.Name(type), object: nil)
            }else {
            NotificationCenter.default.post(name: Notification.Name("gotoChat"), object: nil)
        }
        completionHandler()
    }
    
//    func application(received remoteMessage: MessagingRemoteMessage) {
//        print(remoteMessage.appData)
//    }
    
    public func showSignIn(_ videoId:String? = nil){
        if UserDefaultManager.instance.user == nil{
            let launchScreenVC = UIStoryboard.init(name: "SignIn", bundle: nil)
            let rootVC = launchScreenVC.instantiateViewController(withIdentifier: "SignInViewController")
            self.window?.rootViewController = rootVC
        }else{
            let launchScreenVC = UIStoryboard.init(name: "Home", bundle: nil)
            let rootVC = launchScreenVC.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
            rootVC.videoId = videoId
            self.window?.rootViewController = rootVC
        }
        self.window?.makeKeyAndVisible()
      
    }
    
//
//    func getAllFunVideos(startPoint:String){
//        NetworkUtil.request(dataType:ReelResponse.self,apiMethod:Constants.URL.getReels(page:0, limit: "20", userId: UserDefaults.standard.string(forKey: "user_id") ?? "6332a8b8e2ef3837689e4ba5", categoryId: "1"), parameters: nil, onSuccess: {data in
//            if data.status {
//                for i in 0..<data.reel.count {
//                    let obj = data.reel[i]
//
//                   // self.saveVideoIntoDocs(vID:obj._id, vURL: obj.video ?? "")
//                }
//            }else{
//
//            }
//        }) { errorType,error in
//
//            print("error--",error)
//        }
//    }
//
//    func getAllTalentVideos(startPoint:String){
//        NetworkUtil.request(dataType:ReelResponse.self,apiMethod:Constants.URL.getReels(page:0, limit: "20", userId: UserDefaults.standard.string(forKey: "user_id") ?? "6332a8b8e2ef3837689e4ba5", categoryId: "2"), parameters: nil, onSuccess: {data in
//            if data.status {
//
//                for i in 0..<data.reel.count {
//                    let obj = data.reel[i]
//
//                    //self.saveVideoIntoDocs(vID:obj._id, vURL: obj.video ?? "")
//                }
//            }else{
//
//            }
//        }) { errorType,error in
//
//            print("error--",error)
//        }
//    }
    
    func getAllService(){
        NetworkUtil.request(dataType:ServiceProviderModel.self,apiMethod:Constants.URL.service, parameters: nil, onSuccess: {provider in
          Constants.servicesArray.removeAll()
          
          if provider.status {
            Constants.servicesArray = provider.service
          }else{
            print("error - - - ")
          }
        }) { _,error in
          print("error--",error)
        }
      }
    
    func getSongsList() {
        NetworkUtil.request(apiMethod: Constants.URL.songs, parameters: nil, requestType: .get, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            guard let data = data as? Data else {
                print("cast error")
                return
            }
            print(String(data: data, encoding: .utf8) ?? "")
            do{
                let songs = try JSONDecoder().decode(GetSongModel.self, from:  data)
                print(songs.song.count)
                if songs.song.count > 0{
                    for i in 0..<songs.song.count {
                        let obj = songs.song[i]
                        // let replaced = obj.song.replacingOccurrences(of: "\\", with: "/")
                        
                        //let audioUrl1 = replaced.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        
                        if let audioUrl = URL(string: obj.song ) {
                            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            
                            // lets create your destination file url
                            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent )
                            print(destinationUrl)
                            
                            // to check if it exists before downloading it
                            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                            }else {
                                
                                URLSession.shared.downloadTask(with: audioUrl) {location, response, error in
                                    guard let location = location, error == nil else { return }
                                    do {
                                        // after downloading your file you need to move it to your destination url
                                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                                        print("File moved to documents folder")
                                        
                                    } catch {
                                        print(error)
                                    }
                                }.resume()
                            }
                        }
                    }
                }
                
            } catch {
                print("error: ", error)
            }
            
        }) { _,error in
            print("error--",error)
        }
    }
    
    func convertToDictionary(from text: String) throws -> [String: Any] {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any] ?? [:]
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "TalentCashModel")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {

                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()

        // MARK: - Core Data Saving support

        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    
    func saveVideoIntoDoca(remoteUrl:String, completion: ((_ outputUrl: String) -> Void)? = nil){

        var videoUrl = remoteUrl
        var resultURL = ""

        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        let timestamp = dateFormatter.string(from: Date())
        let destPath = NSString(string: documentPath).appendingPathComponent("\(timestamp).mp4") as String

        if FileManager.default.fileExists(atPath: destPath) {
            print("file already exist at \(destPath)")
            //self.playVideo(NSURL(fileURLWithPath: destPath))
            resultURL = destPath
            completion?(resultURL)
          
        }
        let url = URL(string: videoUrl)!

            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            session.configuration.timeoutIntervalForRequest = 120
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {

                        if response.statusCode == 200
                        {
                            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
//                                        self.saveAndUpdateVideoData(remoteUrl:url.absoluteString, vURL:
                                    //destinationUrl.absoluteString)
                                    
                                    resultURL = destinationUrl.absoluteString
                                    
                                    completion?(resultURL)
                                }
                                else
                                {
                                    print(error?.localizedDescription ?? "")
                                    completion?(resultURL)
                                }
                            }
                            else
                            {
                                print(error?.localizedDescription ?? "")
                                completion?(resultURL)
                            }
                        }
                    }
                }
                else
                {
                    print(error?.localizedDescription ?? "")
                    completion?(resultURL)
                }
            })
            task.resume()
   
        }



//     func saveAndUpdateVideoData(remoteUrl:String,vURL:String){
//
//         let context = persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Videos")
//
//        fetchRequest.predicate = NSPredicate(format: "remoteUrl = %@",
//                                                 argumentArray: [remoteUrl])
//
//        do {
//            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
//            if results?.count != 0 { // Atleast one was returned
//                results?[0].setValue(remoteUrl, forKey: "remoteUrl")
//                results?[0].setValue(vURL, forKey: "localUrl")
//            }else{
//                let entity = NSEntityDescription.entity(forEntityName: "Videos", in:  context) ??  NSEntityDescription()
//                let addValue = NSManagedObject(entity: entity, insertInto: context)
//                addValue.setValue(remoteUrl, forKey: "remoteUrl")
//                addValue.setValue(vURL, forKey: "localUrl")
//            }
//        } catch {
//            print("Fetch Failed: \(error)")
//        }
//
//        do {
//            try context.save()
//           }
//        catch {
//            print("Saving Core Data Failed: \(error)")
//        }
//    }
    
    func getLocalVideoData(remoteUrl:String)->String{

        var localUrl:String = ""
        let context = persistentContainer.viewContext
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Videos")

       fetchRequest.predicate = NSPredicate(format: "remoteUrl = %@",
                                                argumentArray: [remoteUrl])

       do {
           let results = try context.fetch(fetchRequest) as? [NSManagedObject]
           if results?.count != 0 { // Atleast one was returned
               localUrl =   results?[0].value(forKey: "localUrl") as? String ?? ""
           }
       } catch {
           print("Fetch Failed: \(error)")
       }

       do {
           try context.save()
          }
       catch {
           print("Saving Core Data Failed: \(error)")
       }

        return localUrl
   }
    
//    func cleanUp() {
//        let maximumDays = 2.0
//        let minimumDate = Date().addingTimeInterval(-maximumDays*24*60*60)
//        func meetsRequirement(date: Date) -> Bool { return date < minimumDate }
//
//       // func meetsRequirement(name: String) -> Bool { return name.hasPrefix(applicationName) && name.hasSuffix("log") }
//
//        do {
//            let manager = FileManager.default
//            let documentDirUrl = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            if manager.changeCurrentDirectoryPath(documentDirUrl.path) {
//                for file in try manager.contentsOfDirectory(atPath: ".") {
//                    let creationDate = try manager.attributesOfItem(atPath: file)[FileAttributeKey.creationDate] as! Date
//                    if meetsRequirement(date: creationDate) {
//                        self.deleteAllData("Videos")
//                        if file.contains("mp4") || file.contains("mov"){
//                            try manager.removeItem(atPath: file)
//                        }
//                    }
//                }
//            }
//        }
//        catch {
//            print("Cannot cleanup the old files: \(error)")
//        }
//    }

//    func deleteAllData(_ entity:String) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        fetchRequest.returnsObjectsAsFaults = false
//        do {
//            let results = try persistentContainer.viewContext.fetch(fetchRequest)
//            for object in results {
//                guard let objectData = object as? NSManagedObject else {continue}
//                persistentContainer.viewContext.delete(objectData)
//            }
//        } catch let error {
//            print("Detele all data in \(entity) error :", error)
//        }
//    }

}



