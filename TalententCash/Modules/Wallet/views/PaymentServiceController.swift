//
//  CoinController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 06/10/2022.
//

import UIKit
import Alamofire

class PaymentServiceController: UIViewController {

    var payProClicked:()->Void = { }
    var jazzCashClicked:()->Void = { }
    var payMobClicked:()->Void = { }
    @IBAction func backLayerTap(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func payProClick(_ sender: Any) {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name("dismissPaymentService"), object: nil, userInfo:nil)
        self.dismiss(animated: true)
       
  
    }
    @IBAction func payMob(_ sender: Any) {
        
        self.dismiss(animated: true)
        //NotificationCenter.default.post(name: Notification.Name("dismissPaymentServicePaymob"), object: nil, userInfo:nil)
        //self.dismiss(animated: true)
     
        
    }
    @IBAction func jazzCash(_ sender: Any) {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name("dismissPaymentServicejazz"), object: nil, userInfo:nil)
        self.dismiss(animated: true)
    }
}
