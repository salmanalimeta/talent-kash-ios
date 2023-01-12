//
//  TransactionReceiptController.swift
//  Talent Cash
//
//  Created by Aamir on 08/12/2022.
//

import UIKit
import Alamofire

class TransactionReceiptController:StatusBarController{
    @IBOutlet weak var dateLabel: UILabel!
       @IBOutlet weak var receiptId: UILabel!
       @IBOutlet weak var coinLabel: UILabel!
       @IBOutlet weak var timeLabel: UILabel!
       @IBOutlet weak var amountLabel: UILabel!
       
       override func viewDidLoad() {
           
   //        self.receiptId.text = "ID#"+(UserDefaults.standard.string(forKey: "OrderNumber") ?? "")
   //        self.coinLabel.text = (UserDefaults.standard.string(forKey: "selectCoins") ?? "")+" Coins"
   //        self.amountLabel.text = (UserDefaults.standard.string(forKey: "selectReuppes") ?? "")+" PKR"
   //
   //        let fullNameArr = (UserDefaults.standard.string(forKey: "OrderDate") ?? "2022-10-10T15:44:12.17").components(separatedBy: "T")
   //
   //        let val1 = fullNameArr[0]
   //        let val2 = fullNameArr[1]
   //
   //        let dateFormatter = DateFormatter()
   //        dateFormatter.dateFormat = "yyyy-MM-dd"
   //        let date = dateFormatter.date(from: val1)
   //        dateFormatter.dateFormat = "dd/MM/yyyy"
   //        let resultString = dateFormatter.string(from: date!)
   //        self.dateLabel.text = resultString
   //
   //        let fullNameArr1 = val2.components(separatedBy: ".")
   //
   //        let dateFormatter1 = DateFormatter()
   //        dateFormatter1.dateFormat = "HH:MM:SS"
   //        let date1 = dateFormatter1.date(from: fullNameArr1[0])
   //        dateFormatter1.dateFormat = "hh:mm a"
   //        let resultString1 = dateFormatter1.string(from: date1!)
   //        self.timeLabel.text = resultString1
           
           self.getOrderDetail()
           
       }
       
    func getOrderDetail() {
        self.startPulseAnimation()
        NetworkUtil.request(dataType:coinsHistoryDetailModel.self,apiMethod: Constants.URL.walletHistoryDetail+(UserDefaultManager.instance.userID)+"&orderId=\((UserDefaults.standard.string(forKey: "OrderNumber") ?? "0"))", parameters:nil, requestType: .get, onSuccess: {actDataSource in
            self.stopPulseAnimation()
            if actDataSource.status == true{
                self.receiptId.text = actDataSource.coinDetails?.order_id
                self.coinLabel.text = "\(actDataSource.coinDetails?.coins ?? 0) Coins"
                self.amountLabel.text = "\(actDataSource.coinDetails?.amount ?? 0) PKR"
                self.dateLabel.text = actDataSource.coinDetails?.order_date
                let fullNameArr = actDataSource.coinDetails?.order_datetime?.components(separatedBy: ",")
                let val1 = fullNameArr?[0]
                let val2 = fullNameArr?[1]
                if val2 == nil{
                    self.timeLabel.text = actDataSource.coinDetails?.order_datetime
                }else{
                    self.timeLabel.text = val2?.trimmingCharacters(in: .whitespaces)
                }
            }else{
                self.showToast(message:actDataSource.message ?? "", font: UIFont.systemFont(ofSize: 12.0))
            }
        }) { _,error in
            self.stopPulseAnimation()
            print("error--",error)
        }
    }
       
       @IBAction func closeButtonClick(_ sender: Any) {
           dismiss(animated: true)
       }
       
       @IBAction func backButtonClick(_ sender: Any) {
           dismiss(animated: true)
       }
   }
