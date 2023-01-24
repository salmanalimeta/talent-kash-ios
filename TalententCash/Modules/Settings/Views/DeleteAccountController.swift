//
//  DeleteAccountController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 23/12/2022.
//

import UIKit

class DeleteAccountController: UIViewController {
    var onDeleteClick:()->Void = {}
    @IBAction func yesButtonClick(_ sender: Any) {
        onDeleteClick()
    }
    @IBAction func NoButtonClick(_ sender: Any) {
        dismiss(animated: true)
    }
}
