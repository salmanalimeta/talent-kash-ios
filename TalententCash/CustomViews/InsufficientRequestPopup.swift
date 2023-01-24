//
//  InsufficientRequestPopup.swift
//  Talent Cash
//
//  Created by MacBook Pro on 28/12/2022.
//

import UIKit
import Reusable

class InsufficientRequestPopup: UIView,NibOwnerLoadable {
    var onRecharchWalletClick:()->Void = { }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func onRechargeButtonClick(_ sender:Any){
        onRecharchWalletClick()
        self.removeFromSuperview()
    }
    @IBAction func onCancelButtonClick(_ sender:Any){
        removeFromSuperview()
    }
}
