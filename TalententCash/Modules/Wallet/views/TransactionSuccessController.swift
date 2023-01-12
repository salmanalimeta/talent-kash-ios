//
//  CoinController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 06/10/2022.
//

import UIKit

class TransactionSuccessController: StatusBarController {
    @IBOutlet weak var successDescLabel: UILabel!
    
    @IBOutlet weak var transView: BorderedButton!
    var selectReuppes:String = ""
    var selectCoins:String = ""
    var isStatus:String = "true"
    @IBOutlet weak var viewImage: UIImageView!
    
    @IBOutlet weak var txtheader: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if isStatus == "true"{
            setTransactionDescription(coin:selectCoins,price:selectReuppes)
            txtheader.text =  "Transaction Successful !"
        
            self.transView.alpha = 1
            self.viewImage.image = UIImage(named:"check.large.wallet")
         
        }else{
            
            setTransactionFailDescription(coin:selectCoins,price:selectReuppes)
            txtheader.text =  "Failed Transaction !"
            self.transView.alpha = 0
            self.viewImage.image = UIImage(named:"Subtract")
         
           
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionReceiptController"{
            
        }
    }
    
    private func setTransactionDescription(coin:String,price:String){
        let firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
        let firstString = NSMutableAttributedString(string: "\(coin) Coins ", attributes: firstAttributes)
        let secondString = NSAttributedString(string: " have been recharged in your wallet against ", attributes: secondAttributes)
        let thirdString = NSAttributedString(string: "\(price) PKR",attributes: firstAttributes)
        firstString.append(secondString)
        firstString.append(thirdString)
        successDescLabel.attributedText  = firstString
    }
    
    
    private func setTransactionFailDescription(coin:String,price:String){
        
        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
  
        let secondString = NSAttributedString(string: "Your Transection have been failed pleasse try again", attributes: secondAttributes)
     
        successDescLabel.attributedText  = secondString
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func viewTransaction(_ sender: Any) {
        let vc = UIStoryboard.init(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "TransactionReceiptController") as! TransactionSuccessController
        self.present(vc , animated: true)
        
    }
    
}
