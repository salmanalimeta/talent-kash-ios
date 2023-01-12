//
//  PhoneViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 19/09/2022.
//

import UIKit
import CountryPickerView
import Alamofire

class PhoneViewController: StatusBarController, CountryPickerViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var btnCountry: UIButton!
    
    @IBOutlet weak var txtPhone: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    let countryPickerView = CountryPickerView()
    
    var userDataSource : QuickLoginModel!
    private var isPasswordHidden = true
    override func viewDidLoad() {
        super.viewDidLoad()
        //txtPhone.delegate = self
        countryPickerView.delegate = self
        txtPhone.addTarget(
            self,
            action: #selector(textFieldChangedValue(_:)),
            for: .editingChanged
        )
        // Do any additional setup after loading the view.
    }
    @IBAction func selectCountry(_ sender: Any) {
        
        countryPickerView.showCountriesList(from: self)
    }
    
    @IBAction func textFieldChangedValue(_ sender: UITextField) {
       if self.txtPhone.text?.count ?? 0 > 10{
           _ = self.txtPhone.text?.popLast()
        }
    }
    
    @IBAction func showPasswordTap(_ sender: UIButton) {
        isPasswordHidden.toggle()
        sender.setImage(UIImage(named: "password.\(isPasswordHidden ? "hide" : "show")"), for: .normal)
        txtPassword.isSecureTextEntry = isPasswordHidden
    }
    @IBAction func tabogin(_ sender: Any) {
        
        if self.txtPhone.text?.count ?? 10 < 8{
            self.showToast(message: "Please enter valid phone number.", font: UIFont.systemFont(ofSize: 12.0))
        }else if self.txtPassword.text?.isEmpty ?? true{
            self.showToast(message: "Please enter your password.", font: UIFont.systemFont(ofSize: 12.0))
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
//        let code:String! = self.btnCountry.titleLabel?.text
        let phone:String! = self.txtPhone.text
//        let number = code+phone
        self.startPulseAnimation()
        NetworkUtil.request(apiMethod: Constants.URL.lginWithPhone , parameters: ["userNumber": phone ?? "","loginType":"3","fcm_token":UserDefaults.standard.string(forKey: "DeviceToken") ?? "","password":self.txtPassword.text ?? ""], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
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
                            
                            self.showToast(message:self.userDataSource.message , font: UIFont.systemFont(ofSize: 12.0))
                        }

                    } catch {
                        print("error: ", error)
                    }
                    
                }) { _,error in
                    self.stopPulseAnimation()
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

            let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                       let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
                               vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
  
    }

}
