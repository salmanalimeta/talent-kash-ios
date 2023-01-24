//
//  AcceptProviderController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 28/09/2022.
//

import UIKit
import KDCircularProgress
import Alamofire

class AcceptProviderController: StatusBarController {
    private let waitingDuration:Double = 30
    
    @IBOutlet weak var txtServiceName: UILabel!
    
    @IBOutlet weak var txtPrice: UILabel!
    @IBOutlet weak var txtRequest: UILabel!
    
    @IBOutlet weak var txtDescription: UILabel!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var circularProgress: KDCircularProgress!
    
    @IBOutlet weak var btnAccept: ButtonGradientBackground!
    
    @IBOutlet weak var btnReject: ButtonGradientBackground!

    var requestID:String = "0"
    var user_id:String = "0"
    var reel_id:String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var i = waitingDuration
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { t in
            self.progressLabel.text = "\(Int(i)) Seconds"
            if i == 0{
                t.invalidate()
                self.progressLabel.text = "Done"
                self.dismiss(animated: true)
            }
            i -= 1
        })
        circularProgress.animate(toAngle: 360, duration: waitingDuration, completion: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification),
                                               name: Notification.Name("RequestFromUserData"),
                                               object: nil)
    }
    
    
    @objc func handleNotification(notification: NSNotification) {
        
        if let dict = notification.object as? NSDictionary {
            print("accept price = ",dict)
        if let service_price = dict["service_price"] as? Int , let service = dict["service"] as? String , let name = dict["name"] as? String{
            txtPrice.text = "Price: \(service_price) PKR"
            txtServiceName.text = "Service Name: "+service
            txtRequest.text = name+" Sent you a request"
            self.requestID = dict["_id"] as? String ?? "0"
            self.user_id = dict["userId"] as? String ?? "0"
           // self.reel_id = dict["reelId"] as? String ?? "0"
            
        }
        
        if let description = dict["description"] as? String{
            
            txtDescription.text = "Description: "+description
       
        }

    }
}
    
    func tabOnNotification(status:String){
        
        let parameters = ["userId":self.user_id ,"reelId":requestID,"description":self.txtDescription.text ?? "","status":status,"talentId":(UserDefaultManager.instance.userID)]
        
        print(parameters)
    
        self.startPulseAnimation()
        NetworkUtil.request(apiMethod: Constants.URL.sendStatusToUser ,parameters:parameters , requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
        
             self.stopPulseAnimation()
            guard let data = data as? Data else {
                return
            }
            print("ddd= ",String(data: data, encoding: .utf8) ?? "")
            do{
                let available = try JSONDecoder().decode(OTPModel.self, from:  data)
                if status == "accepted"{
                    
                    do{
                        
                        let anyResult: Any = try JSONSerialization.jsonObject(with:data, options: [])
                        let dic = anyResult as? [String: Any] ?? [:]
                        
                        if let dict = dic["payload"] as? NSDictionary{
                            
                            if let data1 = dict["data"] as? NSDictionary{
                                
                                if let data2 = data1["data"] as? NSDictionary{
                                    
                                    if let bookingId = data2["bookingId"] as? String{
                                        
                                        let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
                                        let vc = st.instantiateViewController(withIdentifier: "ConfirmProviderConntroller") as! ConfirmProviderConntroller
                                        vc.bookeID = bookingId
                                        vc.OtherID = self.user_id
                                        vc.modalPresentationStyle = .fullScreen
                                        self.present(vc, animated: true)
                                    }
                                    
                                }
                            }
                        }
                      
                        
                    }catch{
                        
                        
                    }
                   

                  
                }else{

                    let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
                    let vc = st.instantiateViewController(withIdentifier: "OopsProvideConntroller") as! OopsProvideConntroller
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }


            } catch {
                print("error: ", error)
            }
            
        }) { _,error in
            print("error--",error)
        }

    }
    
    @IBAction func backClick(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tabAccepty(_ sender: Any) {
       
        self.tabOnNotification(status: "accepted")
    }
    
    @IBAction func tabDecline(_ sender: Any) {
      
        self.tabOnNotification(status: "rejected")
    }
    

}
