//
//  SignInViewController.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 08/09/2022.
//

import UIKit
import Alamofire
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import GSPlayer
import AuthenticationServices


class SignInViewController: StatusBarController, GIDSignInDelegate{
  
    

//    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var blurImage: UIImageView!
    
    var userDataSource : QuickLoginModel!
    
    var first_name:String! = ""
    var last_name:String! = ""
    var email:String! = ""
    var socialID:String! = ""
    var profile_pic:String! = ""
    var signUPType:String! = ""
    var authToken:String! = ""
    var pass:String! = ""
    var dob:String! = ""
    var my_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async {
            self.getAllTalentVideos(startPoint: "0")
             self.getAllFunVideos(startPoint: "0")
        }
    }
    
    @IBAction func loginWithFB(_ sender: Any) {
        
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                    }
                }
            }
        }
        
    }
    
    @available(iOS 13.0, *)
    @IBAction func loginWithApple(_ sender: Any) {
        
        self.setupAppleIDCredentialObserver()
        let appleSignInRequest = ASAuthorizationAppleIDProvider().createRequest()
        appleSignInRequest.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [appleSignInRequest])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
        
        
    }
    
    @available(iOS 13.0, *)
    private func setupAppleIDCredentialObserver() {
        let authorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
        authorizationAppleIDProvider.getCredentialState(forUserID: "currentUserIdentifier") { (credentialState: ASAuthorizationAppleIDProvider.CredentialState, error: Error?) in
            if let error = error {
                print(error)
                // Something went wrong check error state
                return
            }
            switch (credentialState) {
            case .authorized:
                //User is authorized to continue using your app
                
                print("authorized")
                break
            case .revoked:
                //User has revoked access to your app
                break
            case .notFound:
                //User is not found, meaning that the user never signed in through Apple ID
                break
            default: break
            }
        }
    }
  
    func getAllFunVideos(startPoint:String){
        NetworkUtil.request(dataType:ReelResponse.self,apiMethod:Constants.URL.getReels(page:0, limit: "20", userId: UserDefaultManager.instance.user?._id ?? "6332a8b8e2ef3837689e4ba5", categoryId: "1",userSpecificReels: false), parameters: nil, onSuccess: {data in
            if data.status {
//                let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? AppDelegate()
////                VideoPreloadManager.shared.set(waiting: data.reel.map({ reel in
////                    return URL(string:reel.video ?? "") ?? URL(fileURLWithPath: "")
////                }))
                //var items: [URL] = []
//                for i in 0..<data.reel.count {
//                    let obj = data.reel[i]
//
//                    appDelegate.saveVideoIntoDoca(remoteUrl: obj.video ?? "")
//                   // items.insert(URL(string: obj.video ?? "")!, at: i)
//                }
                VideoPreloadManager.shared.set(waiting:data.reel.filter({$0.video != nil}).map({URL(string: $0.video!)!}))
            }else{
                
            }
        }) { errorType,error in
        
            print("error--",error)
        }
    }
    
    func getAllTalentVideos(startPoint:String){
        NetworkUtil.request(dataType:ReelResponse.self,apiMethod:Constants.URL.getReels(page:0, limit: "20", userId: UserDefaultManager.instance.user?._id ?? "6332a8b8e2ef3837689e4ba5", categoryId: "2",userSpecificReels: false), parameters: nil, onSuccess: {data in
            if data.status {
   
               // var items: [URL] = []
//                let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? AppDelegate()
//                for i in 0..<data.reel.count {
//                    let obj = data.reel[i]
//
//                    appDelegate.saveVideoIntoDoca(remoteUrl: obj.video ?? "")
//                   // items.insert(URL(string: obj.video ?? "")!, at: i)
//                }
                VideoPreloadManager.shared.set(waiting: data.reel.filter({$0.video != nil}).map({URL(string: $0.video!)!}))
               // VideoPreloadManager.shared.set(waiting:items)
            }else{
                
            }
        }) { errorType,error in
        
            print("error--",error)
        }
    }
    
    func getFBUserData(){
       
        self.startPulseAnimation()
        if((AccessToken.current) != nil){
            
            print("access token fb: ",AccessToken.current!)
            //["fields": "id, name, first_name, last_name, picture.type(large), email,age_range"]
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email,age_range"]).start(completion: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as! [String : AnyObject]
                    print(dict)
                    if let dict = result as? [String : AnyObject]{
                        if(dict["email"] as? String == nil || dict["id"] as? String == nil || dict["email"] as? String == "" || dict["id"] as? String == "" ){
                            self.stopPulseAnimation()
                            self.showToast(message:"You cannot login with this facebook account because your facebook is not linked with any email", font: UIFont.systemFont(ofSize: 12.0))
                            
                        }else{
                            
                            //                            MARK:- FB DATA
                            //                            HomeViewController.removeSpinner(spinner: sv)
                            self.stopPulseAnimation()
                            self.email = dict["email"] as? String
                            self.first_name = dict["first_name"] as? String
                            self.last_name = dict["last_name"] as? String
                            self.my_id = (dict["id"] as? String)!
                            let dic1 = dict["picture"] as! NSDictionary
                            let pic = dic1["data"] as! NSDictionary
                            self.profile_pic = pic["url"] as? String
                            self.socialID = dict["id"] as? String
                            self.authToken = AccessToken.current?.tokenString
                            
                            print("email: ",dict["email"] as? String)
                            
                            
                            print("email: \(self.email), name: \(self.my_id)")
                            
                            self.signUPType = "facebook"
                            self.checkSocialLogin(socialID:self.my_id, loginType: "1",userEmail: self.email,userName: self.first_name+" "+self.last_name)
                            
                        }
                    }
                    
                }else{
                    self.stopPulseAnimation()

                }
            })
        }
        
    }
    
    @IBAction func loginWithGmail(_ sender: Any) {
        
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func quickLogin() {
        self.startPulseAnimation()
        NetworkUtil.request(dataType: QuickLoginModel.self,apiMethod: Constants.baseUrl+"user" , parameters: ["email": "2795f2c0df2c01977", "identity": "2795f2c0df2c0177", "name": "Sasha", "username": "2795f2c0df2c0177","loginType":"2"], requestType: .post, onSuccess: {data in
            self.stopPulseAnimation()
            self.userDataSource = data
            if self.userDataSource.status == true{
                UserDefaultManager.instance.user = self.userDataSource.user
                DispatchQueue.main.async {
                    self.goToHomeScene()
                }
            }else{
                self.showToast(message:self.userDataSource.message , font: UIFont.systemFont(ofSize: 12.0))
            }
        }) { _,error in
            print("error--",error)
        }
    }
    
    func checkSocialLogin(socialID:String,loginType:String,userEmail:String,userName:String) {
        let token:String! = UserDefaults.standard.string(forKey: "DeviceToken")
        NetworkUtil.request(dataType:QuickLoginModel.self,apiMethod: Constants.URL.checkSocialUserExists , parameters: ["social_id": socialID,"loginType":loginType,"fcm_token":token ?? ""], requestType: .post, onSuccess: {data in
            self.stopPulseAnimation()
            self.userDataSource = data
            if self.userDataSource.status == true{
                UserDefaultManager.instance.user = self.userDataSource.user
                DispatchQueue.main.async {
                    self.goToHomeScene()
                }
            }else{
                let st:UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
                let vc = st.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                
                vc.loginType = loginType
                vc.email = userEmail
                vc.name = userName
                vc.social_id = socialID
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }) { _,error in
            self.stopPulseAnimation()
            print("error--",error)
        }
    }
    
    
    
    @IBAction func quickLoginBtn(_ sender: Any) {
        quickLogin()

    }
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
                           vc.modalPresentationStyle = .fullScreen
                           self.present(vc, animated: true, completion: nil)
        AppAnalytic.shared.postAnalyticsEvent(event: .LoginButton)
    }

    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //UIActivityIndicatorView.stopAnimating()
    }
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)  {
        
        if (error == nil) {
            // Perform any operations on signed in user here.
            self.GoogleApi(user: user)
            
            // ...
        } else {
            
            //            self.view.isUserInteractionEnabled = true
            //            KRProgressHUD.dismiss {
            //                print("dismiss() completion handler.")
            //
            //            }
            print("\(error.localizedDescription)")
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        
    }
    
    
    func GoogleApi(user: GIDGoogleUser!){
        self.startPulseAnimation()
        if(user.profile.email == nil || user.userID == nil || user.profile.email == "" || user.userID == ""){
            self.stopPulseAnimation()
            self.showToast(message: "You cannot signup with this Google account because your Google is not linked with any email.", font: UIFont.systemFont(ofSize: 12.0))
        }else{
            self.checkSocialLogin(socialID:user.userID, loginType: "0",userEmail: user.profile.email,userName: user.profile.name)
        }
    }
}
extension SignInViewController: ASAuthorizationControllerDelegate{
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        print("User ID: \(appleIDCredential.user)")
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print(appleIDCredential)
        case let passwordCredential as ASPasswordCredential:
            print(passwordCredential)
        default: break
        }
        
        
        if let userEmail = appleIDCredential.email {
            print("Email: \(userEmail)")
            self.email = userEmail
            self.my_id = appleIDCredential.user
            self.socialID = appleIDCredential.user
        }
        
        if let userGivenName = appleIDCredential.fullName?.givenName,
            
            let userFamilyName = appleIDCredential.fullName?.familyName {
            //print("Given Name: \(userGivenName)")
            // print("Family Name: \(userFamilyName)",
            self.my_id = appleIDCredential.user
            self.first_name = userGivenName
            self.last_name = userFamilyName
            self.authToken = "\(appleIDCredential.authorizationCode?.base64EncodedString())"
            self.socialID = appleIDCredential.user
            self.signUPType = "apple"
            print("my id apple: ",my_id)
            //            checkAlreadyRegistered()
            
            
            if let authorizationCode = appleIDCredential.authorizationCode,
                let identifyToken = appleIDCredential.identityToken {
                print("Authorization Code: \(authorizationCode.base64EncodedString())")
                print("Identity Token: \(identifyToken)")
                //First time user, perform authentication with the backend
                //TODO: Submit authorization code and identity token to your backend for user validation and signIn
                
                self.signUPType = "apple"
                self.profile_pic = ""
                self.authToken = "\(authorizationCode.base64EncodedString())"
                self.socialID = appleIDCredential.user
                self.AppleLogin(socialID: self.socialID, loginType: "1", userEmail: self.email, userName: self.first_name+" "+self.last_name)
                //                           self.SignUpApi()
                return
            }
            //                    MARK:- JK
        }else{
            //Next time get data from backend
            print("id: ",appleIDCredential.user)
            self.signUPType = "apple"
            self.profile_pic = ""
            self.authToken = "\(appleIDCredential.authorizationCode!.base64EncodedString())"
            self.socialID = appleIDCredential.user
            
           // UserDefaults.standard.set(self.my_id, forKey: "uid")
            
            self.AppleLogin(socialID: self.socialID, loginType: "1", userEmail: self.email, userName: self.first_name+" "+self.last_name)
            
        }
        
        
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    func AppleLogin(socialID:String,loginType:String,userEmail:String,userName:String) {
        self.startPulseAnimation()
        let token:String! = UserDefaults.standard.string(forKey: "DeviceToken")
        NetworkUtil.request(dataType:QuickLoginModel.self,apiMethod: Constants.URL.checkSocialUserExists , parameters: ["social_id": socialID,"loginType":loginType,"fcm_token":token ?? ""], requestType: .post, onSuccess: { [self] data in
            self.stopPulseAnimation()
            self.userDataSource = data
            if self.userDataSource.status == true{
                UserDefaultManager.instance.user = self.userDataSource.user
                DispatchQueue.main.async {
                    self.goToHomeScene()
                }
            }else{
                let number = Int(random(digits: 10)) ?? 0
                let params = ["phone_number":"+92\(number)","user_role":"user","name":userName ,"password":"12345678","loginType":loginType,"social_id":socialID,"fcm_token":token ?? ""]
                NetworkUtil.request(dataType:QuickLoginModel.self,apiMethod: Constants.URL.userSignup , parameters:params , requestType: .post, onSuccess: {data in
                    self.stopPulseAnimation()
                    UserDefaultManager.instance.user = data.user
                    if data.status == true{
                        DispatchQueue.main.async {
                            self.goToHomeScene()
                        }
                    }else{
                        self.showToast(message:data.message , font: UIFont.systemFont(ofSize: 12.0))
                    }
                }) { _,error in
                    self.stopPulseAnimation()
                    print("error--",error)
                }
            }
        }) { _,error in
            self.stopPulseAnimation()
            print("error--",error)
        }
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.showToast(message:error.localizedDescription)
    }
}

@available(iOS 13.0, *)
extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
