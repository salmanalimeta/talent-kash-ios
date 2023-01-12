//
//  UserBlockAlertConroller.swift
//  Talent Cash
//
//  Created by Aamir on 13/10/2022.
//

import UIKit

class UserBlockAlertConroller:UIViewController{
    var cancelClick:()->Void = {}
    var blockClick:()->Void = {}
    @IBAction func cancelButtonClick(_ sender: Any) {
        cancelClick()
    }
    
    @IBAction func blockButtonClick(_ sender: Any) {
        blockClick()
    }
}
