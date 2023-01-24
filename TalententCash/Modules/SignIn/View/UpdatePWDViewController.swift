//
//  UpdatePWDViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 25/10/2022.
//

import UIKit
import Alamofire

class UpdatePWDViewController: UIViewController {

    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var txtCPassword: UITextField!
    private var isPasswordHidden = true
    private var isCPasswordHidden = true
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    

    @IBAction func showPasswordTap(_ sender: UIButton) {
        isPasswordHidden.toggle()
        sender.setImage(UIImage(named: "password.\(isPasswordHidden ? "hide" : "show")"), for: .normal)
        txtPassword.isSecureTextEntry = isPasswordHidden
    }
    @IBAction func showConfirmPasswordTap(_ sender: UIButton) {
        isCPasswordHidden.toggle()
        sender.setImage(UIImage(named: "password.\(isCPasswordHidden ? "hide" : "show")"), for: .normal)
        txtCPassword.isSecureTextEntry = isCPasswordHidden
    }
    @IBAction func submit(_ sender: Any) {
        
        if self.txtPassword.text?.isEmpty == true{
            
            self.showToast(message: "Please enter your password.", font: UIFont.systemFont(ofSize: 12.0))
        }else if self.txtCPassword.text?.isEmpty == true{
            
            self.showToast(message: "Please enter your confirm password.", font: UIFont.systemFont(ofSize: 12.0))
        }else if self.txtPassword.text != self.txtCPassword.text {
            
            self.showToast(message: "Password should be match with confirm password.", font: UIFont.systemFont(ofSize: 12.0))
        }
        else{
            self.changePassword()
        }
    }
    
    func changePassword() {
        self.startPulseAnimation()
        print(UserDefaults.standard.string(forKey: "pwdID") ?? "0")
        NetworkUtil.request(apiMethod: Constants.URL.forgotPassword , parameters: ["newPass": txtPassword.text ?? "","confirmPass": txtCPassword.text ?? "","userId":UserDefaults.standard.string(forKey: "pwdID") ?? "0"], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            self.stopPulseAnimation()
            guard let data = data as? Data else {
                print("cast error")
                return
            }
            print("data = ",String(data: data, encoding: .utf8) ?? "no")
            do{
                let checkStatus = try JSONDecoder().decode(OTPModel.self, from:  data)
                
                if checkStatus.status == true{
                    
                    self.showToast(message:checkStatus.message , font: UIFont.systemFont(ofSize: 12.0))
                    
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
            self.stopPulseAnimation()
            print("error--",error)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
    
//        vc.OTP = "\(self.userDataSource.user.otp)"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
       
    }
    
    

}
