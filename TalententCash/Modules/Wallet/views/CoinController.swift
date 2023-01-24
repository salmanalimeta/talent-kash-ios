//
//  CoinController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 06/10/2022.
//

import UIKit
import Alamofire
import AcceptSDK

class CoinController: StatusBarController, AcceptSDKDelegate {
    func userDidCancel() {
        //""
    }
    
    func paymentAttemptFailed(_ error: AcceptSDKError, detailedDescription: String) {
        //""
    }
    
    func transactionRejected(_ payData: PayResponse) {
        //""
    }
    
    func transactionAccepted(_ payData:PayResponse) {
        //""
    }
    
    func transactionAccepted(_ payData: PayResponse, savedCardData: SaveCardResponse) {
        //""
    }
    
    func userDidCancel3dSecurePayment(_ pendingPayData: PayResponse) {
        //""
    }
    
  
    
    @IBOutlet weak var tableViewhistoryCoin: UITableView!
    @IBOutlet weak var tableViewCoin: UITableView!
    @IBOutlet weak var coinCard: Gradient!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var myHistoryButton: ButtonGradientBackground!
    @IBOutlet weak var myCoinButton: ButtonGradientBackground!
    var selectReuppes:String = ""
    let KEY: String = "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TlRJMU5qa3NJbTVoYldVaU9pSnBibWwwYVdGc0luMC5LbTJpQzZIamhuQjJYWGxEQTBPT3h3VmF0b2h0ZkJXNk5pWW1HSE95VEQ1cGFqTVRZenltZW43cERobjh2SnNaNWtJSENUcF9vV3VBZktRU0NNZFd6dw=="
    var selectCoins:Int = 0
    var coinsArray:[coins] = []
    var historyArray:[orderCoin] = []
    let accept = AcceptSDK()
    override func viewDidLoad() {
        super.viewDidLoad()
        myHistoryButton.backgroundGradient = false
        self.tableViewCoin.delegate = self
        self.tableViewCoin.dataSource = self
        self.tableViewhistoryCoin.delegate = self
        self.tableViewhistoryCoin.dataSource = self
        self.getAllCoins()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.paymentStatusNotification(notification:)), name: Notification.Name("paymentStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissPaymentServiceNotification(notification:)), name: Notification.Name("dismissPaymentService"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissPaymentServicePaymob(notification:)), name: Notification.Name("dismissPaymentServicePaymob"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissPaymentServicejazz(notification:)), name: Notification.Name("dismissPaymentServicejazz"), object: nil)
        
       
            self.coinLabel.text = "\(UserDefaults.standard.integer(forKey: "user_coins"))"
        
        accept.delegate = self
        
        
        
      




    }
    @IBAction func backButtonClick(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func paymentStatusNotification(notification: Notification) {
        
        if let obj = notification.userInfo as? NSDictionary{
            
            if let statusObj = obj["status"] as? String{
                
                if statusObj == "Success"{
                    
                    let vc = UIStoryboard.init(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "TransactionSuccessController") as! TransactionSuccessController
                    vc.modalPresentationStyle = .fullScreen
                    vc.selectReuppes = UserDefaults.standard.string(forKey: "selectReuppes") ?? "0"
                    vc.selectCoins = UserDefaults.standard.string(forKey: "selectCoins") ?? "0"
                    vc.isStatus = "true"
                    self.present(vc , animated: true) {
                        let updatedCoins = self.selectCoins + UserDefaults.standard.integer(forKey: "user_coins")
                    UserDefaults.standard.set(updatedCoins,forKey: "user_coins")
                        self.coinLabel.text = "\(updatedCoins)"
                    }
                    
                }else{
                    
                    let vc = UIStoryboard.init(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "TransactionSuccessController") as! TransactionSuccessController
                    vc.modalPresentationStyle = .fullScreen
                    vc.selectReuppes = UserDefaults.standard.string(forKey: "selectReuppes") ?? "0"
                    vc.selectCoins = UserDefaults.standard.string(forKey: "selectCoins") ?? "0"
                    vc.isStatus = "false"
                    self.present(vc , animated: true)
                }
            }
        }
        
        
    }
    
    @objc func dismissPaymentServicePaymob(notification: Notification) {

        do {
                   try accept.presentPayVC(vC:self, paymentKey: KEY, saveCardDefault: true, showSaveCard: true, showAlerts: true)
               } catch AcceptSDKError.MissingArgumentError(let errorMessage) {
                   print(errorMessage)
               }  catch let error {
                   print(error.localizedDescription)
               }
        
    }
    
    @objc func dismissPaymentServicejazz(notification: Notification) {
       
        self.startPulseAnimation()
        NetworkUtil.request(dataType:OrderModel.self,apiMethod: Constants.URL.createOrder, parameters:["userId":UserDefaultManager.instance.userID,"coins":UserDefaults.standard.string(forKey: "selectCoins") ?? "0","amount":UserDefaults.standard.string(forKey: "selectReuppes") ?? "0"], requestType: .post, onSuccess: {data in
            self.stopPulseAnimation()
            if data.status == true{
                
                UserDefaults.standard.set(data.orderDate ?? "", forKey: "OrderDate")
                UserDefaults.standard.set(data.order_id ?? "", forKey: "OrderNumber")
                let vc = UIStoryboard.init(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "JazzCashVCViewController") as! JazzCashVCViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc , animated: true)
               
             
                
            }else{
                self.showToast(message:data.message, font: UIFont.systemFont(ofSize: 12.0))
            }
        }) { _,error in
            self.showToast(message:error)
        }
        
    }
    
    @objc func dismissPaymentServiceNotification(notification: Notification) {
        self.startPulseAnimation()
        print(Constants.URL.createOrder)
        
        NetworkUtil.request(dataType:OrderModel.self,apiMethod: Constants.URL.createOrder, parameters:["userId":UserDefaultManager.instance.userID,"coins":UserDefaults.standard.string(forKey: "selectCoins") ?? "0","amount":UserDefaults.standard.string(forKey: "selectReuppes") ?? "0"], requestType: .post, onSuccess: {data in
            self.stopPulseAnimation()
            if data.status == true{
                let vc = UIStoryboard.init(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "WalletWebViewVC") as! WalletWebViewVC
                vc.modalPresentationStyle = .fullScreen
                vc.myURL = data.click2Pay ?? ""
                UserDefaults.standard.set(data.orderDate ?? "", forKey: "OrderDate")
                UserDefaults.standard.set(data.order_id ?? "", forKey: "OrderNumber")
                self.present(vc , animated: true)
                
            }else{
                self.showToast(message:data.message, font: UIFont.systemFont(ofSize: 12.0))
            }
        }) { _,error in
            self.showToast(message:error)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("paymentStatus"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("dismissPaymentService"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("dismissPaymentServicePaymob"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("dismissPaymentServicejazz"), object: nil)
      
    }
    @IBAction func myCoinButtonClick(_ sender: ButtonGradientBackground) {
  
        emptyLabel.isHidden = true
        coinCard.isHidden = false
        tableViewCoin.isHidden = false
        tableViewhistoryCoin.isHidden = true
        myCoinButton.backgroundGradient = true
        myHistoryButton.backgroundGradient = false
        self.getAllCoins()
        
    }
    @IBAction func myHsitoryButtonClick(_ sender: ButtonGradientBackground) {
     
        coinCard.isHidden = true
        tableViewCoin.isHidden = true
        tableViewhistoryCoin.isHidden = false
        myCoinButton.backgroundGradient = false
        myHistoryButton.backgroundGradient = true
        self.tableViewhistoryCoin.delegate = self
        self.tableViewhistoryCoin.dataSource = self
        self.tableViewhistoryCoin.reloadData()
        getAllHistory()
   
    }
    
    func getAllCoins() {
        self.startPulseAnimation()
        NetworkUtil.request(dataType:CoinsModel.self,apiMethod: Constants.URL.walletCoins+"?userId="+(UserDefaultManager.instance.userID), parameters:nil, requestType: .get, onSuccess: {data in
            self.stopPulseAnimation()
                if data.status == true{
                    self.coinsArray =  data.coinPlan
                }else{
                    self.showToast(message:data.message, font: UIFont.systemFont(ofSize: 12.0))
                }
                self.tableViewCoin.reloadData()
        }) { _,error in
            self.stopPulseAnimation()
            print("error--",error)
        }
    }
    
    
    func getAllHistory() {
        emptyLabel.isHidden = true
        self.startPulseAnimation()
        NetworkUtil.request(dataType:OrderHistoryModel.self,apiMethod: Constants.URL.walletHistory+(UserDefaultManager.instance.userID), parameters:nil, requestType: .get, onSuccess: {data in
            self.stopPulseAnimation()
            if data.status == true{
                self.historyArray =  data.orderCoin!
            }else{
                self.showToast(message:data.message ?? "", font: UIFont.systemFont(ofSize: 12.0))
            }
            self.tableViewhistoryCoin.reloadData()
            self.emptyLabel.isHidden = !self.historyArray.isEmpty
        }) { _,error in
            self.emptyLabel.isHidden = !self.historyArray.isEmpty
            self.stopPulseAnimation()
        }
    }
}
extension CoinController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewCoin{
            return coinsArray.count
        }else{
            return historyArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableViewCoin{
            let cell:MyCoinTableViewCell =   tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath) as! MyCoinTableViewCell
            let obj = self.coinsArray[indexPath.row]
            cell.coinLabel.text = "\(obj.coin ?? 0)"
            cell.priceLabel.text = "\(obj.rupee ?? 0) PKR"
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! MyTransactionHistoryTableViewCell
            let obj = self.historyArray[indexPath.row]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let date = dateFormatter.date(from: obj.order_date ?? "11/10/2022")
            dateFormatter.dateFormat = "d MMM yyyy"
            let resultString = dateFormatter.string(from: date!)
            let fullNameArr = obj.order_datetime?.components(separatedBy: ",")
            let val2 = fullNameArr?[1]
            if val2 == nil{
                cell.dateLabel.text = resultString
            }else{
                
                cell.dateLabel.text = resultString+" | "+(val2?.trimmingCharacters(in: .whitespaces) ?? "7:15 AM")
            }
            cell.boughtCoinLabel.text = "Coins Recharged"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableViewCoin{
            let obj = self.coinsArray[indexPath.row]
            self.selectCoins = obj.coin ?? 0
            self.selectReuppes = "\(obj.rupee ?? 0)"
            UserDefaults.standard.set("\(self.selectCoins)", forKey: "selectCoins")
            UserDefaults.standard.set(self.selectReuppes, forKey: "selectReuppes")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentServiceController") as! PaymentServiceController
            self.present(vc, animated: true)
       
        }else{
            let obj = self.historyArray[indexPath.row]
            UserDefaults.standard.set(obj.order_id ?? "", forKey: "OrderNumber")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionReceiptController") as! TransactionReceiptController
            self.present(vc, animated: true)

        }
        
    }
}
