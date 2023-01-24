//
//  RecoverPwdVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 25/10/2022.
//

import UIKit
import CountryPickerView
import Alamofire

class RecoverPwdVC: StatusBarController,CountryPickerViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var btnCountry: UIButton!
    
    @IBOutlet weak var txtPhone: UITextField!
    
    var OTP:String = ""
 
    let countryPickerView = CountryPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        countryPickerView.delegate = self
        txtPhone.addTarget(
            self,
            action: #selector(textFieldChangedValue(_:)),
            for: .editingChanged
        )
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    @IBAction func selectCountry(_ sender: Any) {
        
        countryPickerView.showCountriesList(from: self)
    }
    
    
    @IBAction func textFieldChangedValue(_ sender: UITextField) {
       if self.txtPhone.text?.count ?? 0 > 10{
           _ = self.txtPhone.text?.popLast()
        }
    }
    
    @IBAction func tabRecover(_ sender: Any) {
        
        if self.txtPhone.text?.isEmpty == true{
            
            self.showToast(message: "Please enter phone number.", font: UIFont.systemFont(ofSize: 12.0))
        }
        else{
            self.phoneLogin()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {

        self.btnCountry.setTitle(country.phoneCode, for: .normal)
        }
    
    func phoneLogin() {
        let code:String! = self.btnCountry.titleLabel?.text
        let phone:String! = self.txtPhone.text
        let number = code+phone
        self.startPulseAnimation()
        NetworkUtil.request(apiMethod: Constants.URL.checkNumberExist , parameters: ["userNumber": phone ?? ""], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            self.stopPulseAnimation()
                    guard let data = data as? Data else {
                        print("cast error")
                        return
                    }
                    print("data = ",String(data: data, encoding: .utf8) ?? "no")
                    do{
                        let checkStatus = try JSONDecoder().decode(UserExist.self, from:  data)

                        if checkStatus.status == true{
                            UserDefaults.standard.set(checkStatus.user?._id, forKey: "pwdID")
                            self.codeResend()
                            
                        }else{

                            self.showToast(message:checkStatus.message , font: UIFont.systemFont(ofSize: 12.0))
                        }
              

                    } catch {
                        print("error: ", error)
                    }
                    
                }) { _,error in
                    self.stopPulseAnimation()
                    print("error--",error)
                }

    }
    
    func codeResend() {
        let code:String! = self.btnCountry.titleLabel?.text
        let phone:String! = self.txtPhone.text
        let number = code+phone
        NetworkUtil.request(apiMethod: Constants.URL.generateOTP , parameters: ["userNumber": number], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
           
                    guard let data = data as? Data else {
                        print("cast error")
                        return
                    }
                    print("data = ",String(data: data, encoding: .utf8) ?? "no")
                    do{
                        let checkStatus = try JSONDecoder().decode(OTPModel.self, from:  data)

                        if checkStatus.status == true{
                            print(checkStatus.otp)
                            self.OTP = "\(checkStatus.otp ?? 0)"
                            DispatchQueue.main.async {
                               self.goToHomeScene()
                            }
                           
                        }else{

                            self.showToast(message:checkStatus.message , font: UIFont.systemFont(ofSize: 12.0))
                        }





                    } catch {
                        print("error: ", error)
                    }
                    
                }) { _,error in
                    print("error--",error)
                }

    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            //For mobile numer validation
        if textField.text?.count ?? 0 > 10 {
               
                return false
            }
            return true
        }
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "VerificationViewController") as! VerificationViewController
        let code:String! = self.btnCountry.titleLabel?.text
        let phone:String! = self.txtPhone.text
        let number = code+phone
        vc.phoneNumber = number
        vc.OTP = self.OTP
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
       
    }
 

}
