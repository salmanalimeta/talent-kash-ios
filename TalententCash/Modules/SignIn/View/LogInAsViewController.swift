//
//  LogInAsViewController.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 08/09/2022.
//

import UIKit

class LogInAsViewController: StatusBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginPress(_ sender: UIButton) {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "HomeTabs") as! CustomTabBarController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func loginAsUserTap(_ sender: UIButton) {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "HomeTabs") as! CustomTabBarController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
        
    }
    
}
