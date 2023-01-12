//
//  OrderSuccessfullProviderController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 29/09/2022.
//

import UIKit

class OrderSuccessfullProviderController: StatusBarController {
    @IBOutlet weak var orderCompleteStatusLabel: UILabel!
    @IBOutlet weak var earnLabel: UILabel!
    var bookingId:String = "0000"
    var earnAmount:String = "0000"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderCompleteStatusLabel.text = "Congratulations Order \(bookingId) Completed"
        self.earnLabel.text = "Earned \(earnAmount)"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! InvoiceProviderController).bookId = bookingId
    }
    @IBAction func backButtonClick(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func viewReceiptClick(_ sender: Any) {
        self.performSegue(withIdentifier: "InvoiceProviderController", sender: self)
    }
}
