//
//  ConnfirmConntroller.swift
//  Talent Cash
//
//  Created by MacBook Pro on 27/09/2022.
//

import UIKit

class ConfirmConntroller: StatusBarController {
    
    
    @IBOutlet weak var username: UILabel!
    
    
    @IBOutlet weak var remPrice: UILabel!
    @IBOutlet weak var lblService: UILabel!
    
    var name:String = ""
    var serviceName:String = ""
    var remainingPrice:String = ""
    var initPrice:String = ""
    var serPrice:String = ""
    var bookingID:String = ""
    var userImage:String = ""
    var userID:String = ""
   
    override func viewDidLoad() {
        
        self.username.text = name
        self.lblService.text = serviceName
        self.remPrice.text = remainingPrice
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        dismiss(animated: false)
    }
    @IBAction func backButtonClack(_ sender: Any) {
        self.dismiss(animated: true) {
            UIApplication.topViewController()?.dismiss(animated: false,completion: {
                UIApplication.topViewController()?.dismiss(animated: false)
            })
        }
    }
    @IBAction func trackButtonClick(_ sender: Any) {
//        dismiss(animated: false)
        let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "TrackController") as! TrackController
        vc.name = name
        vc.remainingPrice = remainingPrice
        vc.initPrice = initPrice
        vc.userImage = userImage
        vc.bookingID = bookingID
        vc.serviceValue = serviceName
        vc.sPrice = serPrice
        vc.otherId = userID
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    @IBAction func viewReceipt(_ sender: Any) {
        let st:UIStoryboard = UIStoryboard(name: "Booking", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
        vc.bookingId = bookingID
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
      }
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
                           vc.modalPresentationStyle = .fullScreen
                           self.present(vc, animated: true, completion: nil)
       
    }
}


