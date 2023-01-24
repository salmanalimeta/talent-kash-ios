//
//  OopsProvideConntroller.swift
//  Talent Cash
//
//  Created by MacBook Pro on 30/09/2022.
//

import UIKit

class OopsProvideConntroller: StatusBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.goToHomeScene()
    }
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
                           vc.modalPresentationStyle = .fullScreen
                           self.present(vc, animated: true, completion: nil)
       
    }

}
