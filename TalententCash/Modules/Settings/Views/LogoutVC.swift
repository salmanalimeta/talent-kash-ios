//
//  LogoutVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 04/10/2022.
//

import UIKit
import Alamofire

class LogoutVC: StatusBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func yesTab(_ sender: Any) {
        self.startPulseAnimation()
        NetworkUtil.request(dataType:OTPModel.self,apiMethod: Constants.URL.logout, parameters:["userId":UserDefaultManager.instance.userID], requestType: .post,onSuccess: {data in
            self.stopPulseAnimation()
            if data.status == true{
                UserDefaultManager.instance.user = nil
                let vc = UIStoryboard.init(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                
                vc.modalPresentationStyle = .fullScreen
                self.present(vc , animated: true)
            }else{
                self.showToast(message:data.message, font: UIFont.systemFont(ofSize: 12.0))
            }
        }) { _,error in
            self.stopPulseAnimation()
            print("error--",error)
        }
    }
    
    @IBAction func NoTab(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
}
