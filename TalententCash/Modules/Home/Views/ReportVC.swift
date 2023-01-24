//
//  ReportVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 11/10/2022.
//

import UIKit
import Alamofire

class ReportVC: StatusBarController {
    
    @IBOutlet weak var txtReason: UILabel!
    @IBOutlet weak var btnnSubmit: ButtonGradientBackground!
    @IBOutlet weak var txtTitle: UILabel!
    var reasonnStrng = "Other"
    var reel_id = "0"
    var onReportVideo:()->Void = { }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.txtReason.text = reasonnStrng
        
        
    }
    
    @IBAction func close(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    @IBAction func submit(_ sender: Any) {
        
        if btnnSubmit.titleLabel?.text == "Submit"{
            self.startPulseAnimation()
            NetworkUtil.request(apiMethod: Constants.URL.reportReel , parameters:["reelId":reel_id], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
                self.stopPulseAnimation()
                guard let data = data as? Data else {
                    print("cast error")
                    return
                }
                let obj = try? JSONSerialization.jsonObject(with: data,options: .mutableContainers) as? [String:Any]
                if let status = obj?["status"] as? Bool , let msg = obj?["message"] as? String{
                    if status {
                        self.onReportVideo()
                        self.btnnSubmit.setTitle("Done", for: .normal)
                        self.txtTitle.text = "Thanks for reporting"
                        self.txtReason.text = "We will review your report and if there is a violation of our Community Guidelines, We will take appropriate action."
                        self.txtReason.font = UIFont.systemFont(ofSize: 14)
                    }else{
                        self.showToast(message: msg)
                    }
                }else{
                    self.showToast(message: "System Error - data_parsing_01")
                }
            }) { _,error in
                self.stopPulseAnimation()
                self.showToast(message: error)
            }
        }else{
            self.dismiss(animated: false) {
                UIApplication.topViewController()?.dismiss(animated: true)
            }
        }
        
        
    }
    
}
