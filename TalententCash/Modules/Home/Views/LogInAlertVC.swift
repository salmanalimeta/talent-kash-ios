//
//  LogInAlertVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 20/09/2022.
//

import UIKit
import Alamofire
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class LogInAlertVC: StatusBarController,GIDSignInDelegate {
    
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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginWithGmail(_ sender: Any) {
        
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    func checkSocialLogin(socialID:String,loginType:String,userEmail:String,userName:String) {

        NetworkUtil.request(dataType:QuickLoginModel.self,apiMethod: Constants.URL.checkSocialUserExists , parameters: ["social_id": socialID,"loginType":loginType], requestType: .post, onSuccess: {data in
            self.userDataSource = data
            self.stopPulseAnimation()
            if data.status == true{
                UserDefaultManager.instance.user = data.user
                self.userDataSource = data
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
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
                           vc.modalPresentationStyle = .fullScreen
                           self.present(vc, animated: true, completion: nil)
       
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
        
        print("user.authentication.accessTokenExpirationDate: ",user.authentication.accessTokenExpirationDate)
        
        //        let sv = HomeViewController.displaySpinner(onView: self.view)
        self.startPulseAnimation()
        
        if(user.profile.email == nil || user.userID == nil || user.profile.email == "" || user.userID == ""){
            self.stopPulseAnimation()
       
            self.showToast(message: "You cannot signup with this Google account because your Google is not linked with any email.", font: UIFont.systemFont(ofSize: 12.0))
            
        }else{
        
            
            self.checkSocialLogin(socialID:user.userID, loginType: "0",userEmail: user.profile.name,userName: user.profile.email)
            
            
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
    
    @IBAction func manualLogin(_ sender: Any) {
        
        let st:UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "PhoneViewController") as! PhoneViewController
                           vc.modalPresentationStyle = .fullScreen
                           self.present(vc, animated: true, completion: nil)
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
  
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated:true, completion: nil)
    }
    
}
extension LogInAlertVC: ASAuthorizationControllerDelegate{
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
            
            //checkAlreadyRegistered()
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
        NetworkUtil.request(apiMethod: Constants.URL.checkSocialUserExists , parameters: ["social_id": socialID,"loginType":loginType,"fcm_token":token ?? ""], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: { [self]data in
            self.stopPulseAnimation()
            guard let data = data as? Data else {
                print("cast error")
                return
            }
            print("data = ",String(data: data, encoding: .utf8) ?? "no")
            do{
                self.userDataSource = try JSONDecoder().decode(QuickLoginModel.self, from:  data)
                if self.userDataSource.status == true{
                    UserDefaultManager.instance.user = self.userDataSource.user
                    DispatchQueue.main.async {
                        self.goToHomeScene()
                    }
                }else{
                    let number = Int(random(digits: 10)) ?? 0
                    let
                    params =  ["phone_number":"+92\(number)","user_role":"user","name":userName ,"password":"12345678","loginType":loginType,"social_id":socialID,"fcm_token":token ?? ""]
                    NetworkUtil.request(dataType:QuickLoginModel.self,apiMethod: Constants.URL.userSignup , parameters:params , requestType: .post, onSuccess: {data in
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
                        self.stopPulseAnimation()
                        print("error--",error)
                    }
                }
            } catch {
                print("error: ", error)
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
extension LogInAlertVC: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
