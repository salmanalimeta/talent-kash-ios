//
//  VerificationViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 19/09/2022.
//

import UIKit
import DPOTPView
import Alamofire

class VerificationViewController: StatusBarController {
    
    @IBOutlet weak var otpView: DPOTPView!
    
    @IBOutlet weak var lblNumber: UILabel!
    
    var phoneNumber:String = ""
    
    var OTP:String = ""
    
    var userDataSource : OTPModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.lblNumber.text = "Please type the code sent to "+phoneNumber
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.showToast(message:"Your OTP is:"+self.OTP, font: UIFont.systemFont(ofSize: 12.0))
//        }
//
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
    }
    
    @IBAction func resendCode(_ sender: Any) {
        self.codeResend()
    }
    @IBAction func verifyCode(_ sender: Any) {
        
        if otpView.text?.isEmpty == true{
            
            self.showToast(message:"Please enter otp code.", font: UIFont.systemFont(ofSize: 12.0))
            
        }else{
            
            if self.OTP == otpView.text {
                self.goToHomeScene()
            }else{
                otpView.text = ""
                self.showToast(message:"Your otp code is wrong.", font: UIFont.systemFont(ofSize: 12.0))
            }
        }
    }
    
    func codeResend() {
        self.startPulseAnimation()
        NetworkUtil.request(apiMethod: Constants.URL.generateOTP , parameters: ["userNumber": phoneNumber], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            self.stopPulseAnimation()
                    guard let data = data as? Data else {
                        print("cast error")
                        return
                    }
                    print("data = ",String(data: data, encoding: .utf8) ?? "no")
                    do{
                        self.userDataSource = try JSONDecoder().decode(OTPModel.self, from:  data)

                        if self.userDataSource.status == true{

//                            self.showToast(message:"Your OTP is:"+"\(self.userDataSource.otp ?? 123)", font: UIFont.systemFont(ofSize: 12.0))
                            
                            self.OTP = "\(self.userDataSource.otp ?? 123)"
                           
                        }else{
                            self.showToast(message:self.userDataSource.message)
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
                   let vc = st.instantiateViewController(withIdentifier: "UpdatePWDViewController") as! UpdatePWDViewController
                           vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
       
    }

}
