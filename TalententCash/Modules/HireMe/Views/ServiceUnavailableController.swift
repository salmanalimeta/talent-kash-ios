//
//  ServiceUnavailableController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 27/09/2022.
//

import UIKit

class ServiceUnavailableController:UIViewController{
    
    @IBAction func backToHomeButtonCLick(_ sender: Any) {
        self.dismiss(animated: true) {
            UIApplication.topViewController()?.dismiss(animated: true)
        }
    }
}
