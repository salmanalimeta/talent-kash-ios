//
//  UserBlockAlertConroller.swift
//  Talent Cash
//
//  Created by Aamir on 13/10/2022.
//

import UIKit

class UserBlockedAlertConroller:UIViewController{
    var closeClick:()->Void = {}
    @IBAction func closeButtonClick(_ sender: Any) {
        closeClick()
    }
}
