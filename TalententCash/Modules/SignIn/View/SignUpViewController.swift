//
//  SignUpViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 19/09/2022.
//

import UIKit
import CountryPickerView
import Alamofire

class SignUpViewController: StatusBarController,CountryPickerViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var txtPhone: UITextField!
    
    @IBOutlet weak var btnPhone: UIButton!
    
    @IBOutlet weak var viewTalent: UIView!
    
    @IBOutlet weak var viewNormal: UIView!
    
    @IBOutlet weak var radioTalent: UIImageView!
    
    @IBOutlet weak var radioNormal: UIImageView!
    
    @IBOutlet weak var btnTalent: UIButton!
    
    @IBOutlet weak var btnNormal: UIButton!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    let countryPickerView = CountryPickerView()
    
    var userType:String = "talent_provider"
    var loginType:String = "3"
    var email:String = ""
    var name:String = ""
    var social_id:String = "0"
    
    var userDataSource : QuickLoginModel!
    private var isPasswordHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //txtPhone.delegate = self
        txtPhone.addTarget(
            self,
            action: #selector(textFieldChangedValue(_:)),
            for: .editingChanged
        )
        countryPickerView.delegate = self
        txtName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        txtName.leftViewMode = .always
    }

    @IBAction func showPasswordTap(_ sender: UIButton) {
        isPasswordHidden.toggle()
        sender.setImage(UIImage(named: "password.\(isPasswordHidden ? "hide" : "show")"), for: .normal)
        txtPassword.isSecureTextEntry = isPasswordHidden
    }
    @IBAction func signUp(_ sender: Any) {
        
        if self.txtName.text?.isEmpty == true{
            
            self.showToast(message: "Please enter your name.", font: UIFont.systemFont(ofSize: 12.0))
            
        }else if self.txtPhone.text?.isEmpty == true{
            
            self.showToast(message: "Please enter your phone number.", font: UIFont.systemFont(ofSize: 12.0))
        }else if self.loginType == "3"{
            
            if self.txtPassword.text?.isEmpty == true{
                
                self.showToast(message: "Please enter your password.", font: UIFont.systemFont(ofSize: 12.0))
            }else{
                
                self.doSignup()
            }
        }
        else{
            self.doSignup()
        }
    }
    
    @IBAction func textFieldChangedValue(_ sender: UITextField) {
       if self.txtPhone.text?.count ?? 0 > 10{
           _ = self.txtPhone.text?.popLast()
        }
    }
    @IBAction func selectCountry(_ sender: Any) {
        
        countryPickerView.showCountriesList(from: self)
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated:true, completion: nil)
        
    }
    
    @IBAction func pressTalent(_ sender: Any) {
        
        self.btnNormal.setTitleColor(UIColor.white, for: .normal)
        self.btnTalent.setTitleColor(UIColor(named: "buttonArcSecondColor"), for: .normal)
        self.viewTalent.borderColor = UIColor(named: "buttonArcSecondColor")!
        self.radioTalent.image = UIImage(named: "radioCheck")
        self.viewNormal.borderColor = UIColor.white
        self.radioNormal.image = UIImage(named: "uncheck")
        
        self.userType = "talent_provider"
    }
    
    @IBAction func pressNormal(_ sender: Any) {
        
        self.btnNormal.setTitleColor(UIColor(named: "buttonArcSecondColor"), for: .normal)
        self.btnTalent.setTitleColor(UIColor.white, for: .normal)
        self.viewTalent.borderColor = UIColor.white
        self.radioTalent.image = UIImage(named: "uncheck")
        self.viewNormal.borderColor = UIColor(named: "buttonArcSecondColor")!
        self.radioNormal.image = UIImage(named: "radioCheck")
        
        self.userType = "user"
    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
  
        self.btnPhone.setTitle(country.phoneCode, for: .normal)
        }
    
    
    func doSignup() {
        if txtPhone.text?.count ?? 10 < 8 {
            self.showToast(message: "Please enter valid phone number")
            return
        }
//        let code:String! = self.btnPhone.titleLabel?.text
        let phone:String! = self.txtPhone.text
//        let number = code+phone
        let trimmedEmail = self.txtPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = self.txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let token:String! = UserDefaults.standard.string(forKey: "DeviceToken")
        self.startPulseAnimation()
        var params = ["phone_number":phone,"user_role":self.userType,"name":trimmedName ?? "","user_email":trimmedEmail ?? "","loginType":self.loginType,"fcm_token":token ?? ""] as? [String:Any]
        if loginType == "0" || loginType == "1"{
            params =  ["phone_number":phone ?? "","user_role":self.userType,"name":trimmedName ?? "","password":trimmedEmail ?? "","loginType":self.loginType,"social_id":self.social_id,"fcm_token":token ?? ""]
           
        }else{
            params =   ["phone_number":phone ?? "","user_role":self.userType,"name":trimmedName ?? "","password":trimmedEmail ?? "","loginType":"3","fcm_token":token ?? ""]
        }
        NetworkUtil.request(apiMethod: Constants.URL.userSignup , parameters:params , requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            self.stopPulseAnimation()
                    guard let data = data as? Data else {
                        return
                    }
                    do{
                        self.userDataSource = try JSONDecoder().decode(QuickLoginModel.self, from:  data)
                        if self.userDataSource.status == true{
                            UserDefaultManager.instance.user = self.userDataSource.user
                            DispatchQueue.main.async {
                               self.goToHomeScene()
                            }
                        }else{
                            self.showToast(message:self.userDataSource.message , font: UIFont.systemFont(ofSize: 12.0))
                        }
                    } catch {
                        print("error: ", error)
                    }
                }) { _,error in
                    self.stopPulseAnimation()
                }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            //For mobile numer validation
            if textField == txtPhone {
                let allowedCharacters = CharacterSet(charactersIn:"+0123456789 ")//Here change this characters based on your requirement
                let characterSet = CharacterSet(charactersIn: string)
                return allowedCharacters.isSuperset(of: characterSet)
            }
            return true
        }
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
                           vc.modalPresentationStyle = .fullScreen
                           self.present(vc, animated: true, completion: nil)
        AppAnalytic.shared.postAnalyticsEvent(event: .SignUpButton)
    }
//    func goToHomeScene() {
//        let st:UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
//                   let vc = st.instantiateViewController(withIdentifier: "VerificationViewController") as! VerificationViewController
//        let code:String! = self.btnPhone.titleLabel?.text
//        let phone:String! = self.txtPhone.text
//        let number = code+phone
//        vc.phoneNumber = number
//        //vc.OTP = "\(self.userDataSource.otp ?? 123)"
//
//                           vc.modalPresentationStyle = .fullScreen
//                           self.present(vc, animated: true, completion: nil)
//
//    }
    
}
