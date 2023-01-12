//
//  DeclinedViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 01/10/2022.
//

import UIKit

class DeclinedViewController: StatusBarController {

    @IBOutlet weak var nameUser: UILabel!
    var name:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameUser.text = name
    }
    
    @IBAction func okay(_ sender: Any) {
        self.goToHomeScene()
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
