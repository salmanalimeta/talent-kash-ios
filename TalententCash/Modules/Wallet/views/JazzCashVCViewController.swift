//
//  JazzCashVCViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 30/11/2022.
//

import UIKit
import Alamofire
import CommonCrypto

class JazzCashVCViewController: UIViewController {
    
    @IBOutlet weak var txtCnic: UITextField!
    @IBOutlet weak var txtAccount: UITextField!
    let pp_TxnDateTime:String = "pp_TxnDateTime"
    let pp_TxnExpiryDateTime:String = "pp_TxnExpiryDateTime"
    let pp_TxnRefNo:String = "pp_TxnRefNo"
    let pp_SecureHash:String = "pp_SecureHash"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtAccount.addTarget(
            self,
            action: #selector(textFieldChangedValue(_:)),
            for: .editingChanged)
        
            
            txtCnic.addTarget(
                self,
                action: #selector(textFieldChangedValue(_:)),
                for: .editingChanged)
        
    }
    
    @IBAction func textFieldChangedValue(_ sender: UITextField) {
        if sender == self.txtAccount{
            if self.txtAccount.text?.count ?? 0 > 11{
                _ = self.txtAccount.text?.popLast()
             }
        }else{
            
            if self.txtCnic.text?.count ?? 0 > 6{
                _ = self.txtCnic.text?.popLast()
             }
        }
       
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func proceed(_ sender: Any) {
        
        if txtAccount.text?.isEmpty == true{
            
            self.showToast(message: "Please enter jazz cash account number.")
        }else if txtCnic.text?.isEmpty == true{
            
            self.showToast(message: "Please enter last 6 digit of cnic.")
        }
        else{
            
            self.getSecureHops()
        }
    }
    
    func sendJazzRequest(params:[String:Any]){
        self.startPulseAnimation()

        print(params)
        NetworkUtil.request(apiMethod:"https://payments.jazzcash.com.pk/ApplicationAPI/API/2.0/Purchase/DoMWalletTransaction", parameters: params, requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in

                self.stopPulseAnimation()
                guard let data = data as? Data else {
                    print("cast error")
                    return
                }
                print("data = ",String(data: data, encoding: .utf8) ?? "no")
            if let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]{
                
                if let status = dict["pp_ResponseCode"] as? String{
                    
                    if status == "000"{
                        let transID = dict["pp_TxnRefNo"] as? String
                        self.makeTransaction(transID: transID ?? "0")
                    }else{
                        self.dismiss(animated: true)
                        NotificationCenter.default.post(name: Notification.Name("paymentStatus"), object: nil, userInfo: ["status":"Fail"])
                    }
                }
            }
                
                
            }) { _,error in
                self.stopPulseAnimation()
                print("error--",error)
            
            }
        
    }
    
    
    func getSecureHops(){
        
        self.startPulseAnimation()
        print(Constants.URL.createOrder)
        print(UserDefaults.standard.string(forKey: "selectCoins") ?? "0")
        print(UserDefaults.standard.string(forKey: "selectReuppes") ?? "0")

        NetworkUtil.request(apiMethod: Constants.URL.jazzCashSecureHashForIOS, parameters:["userId":UserDefaultManager.instance.userID,"coins":UserDefaults.standard.string(forKey: "selectCoins") ?? "0","amount":UserDefaults.standard.string(forKey: "selectReuppes") ?? "0","phone":self.txtAccount.text ?? "","app_type":"ios","cnic":self.txtCnic.text ?? ""], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
             self.stopPulseAnimation()
              guard let data = data as? Data else {
                print("cast error")
                return
              }
              print("data = ",String(data: data, encoding: .utf8) ?? "no")
              do{
                let available = try JSONDecoder().decode(OTPModel.self, from: data)
                if available.status == true{
                    
                    if let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]{
                        
                        if let array = dict["postData"] as? NSArray{
                            
                            if let obj = array[0] as? [String: Any]{
                                var param = obj
                                self.sendJazzRequest(params: param)
                            }
                        }
                    }
                   
                    
                  
                }else{
                  self.showToast(message:available.message, font: UIFont.systemFont(ofSize: 12.0))
                }
              } catch {
                print("error: ", error)
              }
            }) { _,error in
                print("error--",error)
              
            }
    }
    
    func makeTransaction(transID:String){
        
        self.startPulseAnimation()
        print(Constants.URL.createOrder)
        print(UserDefaults.standard.string(forKey: "selectCoins") ?? "0")
        print(UserDefaults.standard.string(forKey: "selectReuppes") ?? "0")

        NetworkUtil.request(dataType:OrderModel.self,apiMethod: Constants.URL.jazzCashMakeOrder, parameters:["userId":UserDefaultManager.instance.userID,"coins":UserDefaults.standard.string(forKey: "selectCoins") ?? "0","amount":UserDefaults.standard.string(forKey: "selectReuppes") ?? "0","transaction_id":transID], requestType: .post, onSuccess: {data in
            self.stopPulseAnimation()
            if data.status == true{
          
                self.dismiss(animated: true)
                NotificationCenter.default.post(name: Notification.Name("paymentStatus"), object: nil, userInfo: ["status":"Success"])
                
            }else{
                self.showToast(message:data.message, font: UIFont.systemFont(ofSize: 12.0))
            }
        }) { _,error in
            self.showToast(message:error)
        }
    }
   
  
}
extension Data{
    public func sha256() -> String{
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}



