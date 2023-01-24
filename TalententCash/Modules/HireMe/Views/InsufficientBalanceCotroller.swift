//
//  InsufficientBalanceCotroller.swift
//  Talent Cash
//
//  Created by MacBook Pro on 27/09/2022.
//

import UIKit

class InsufficientBalanceCotroller: StatusBarController {
    
    @IBAction func yesButtonClick(_ sender: Any) {
        dismiss(animated: false) {
            UIApplication.topViewController()?.present((UIStoryboard(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "CoinController")), animated: true)
        }
    }
    @IBAction func NoButtonClick(_ sender: Any) {
        dismiss(animated: false) {
            UIApplication.topViewController()?.dismiss(animated: true)
        }
    }
}
