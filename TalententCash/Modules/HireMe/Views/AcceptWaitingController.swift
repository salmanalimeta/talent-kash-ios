//
//  WaitingController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 20/09/2022.
//

import UIKit
import KDCircularProgress

class AcceptWaitingController: StatusBarController{
    private let waitingDuration:Double = 30
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var circularProgress: KDCircularProgress!
    @IBOutlet weak var txtUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtUserName.text = "Thanks, \(UserDefaults.standard.string(forKey: "user_name") ?? "")"
        var i = waitingDuration
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { t in
            self.progressLabel.text = "\(Int(i)) Seconds"
            if i == 0{
                t.invalidate()
                self.progressLabel.text = "Done"
                self.goToHomeScene()
            }
            i -= 1
        })
        circularProgress.animate(toAngle: 360, duration: waitingDuration, completion: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification),
                                               name: Notification.Name("notFromProvider"),
                                               object: nil)
    }
    
    @objc func handleNotification(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            if let service_price = dict["service_price"] as? Int , let service = dict["service"] as? String , let name = dict["name"] as? String,let initial_Price = dict["initial_price"] as? Int,let bookingId = dict["bookingId"] as? String,let image = dict["userImage"] as? String,let remaining_price = dict["remaining_price"] as? Int,let status = dict["status"] as? String,let userId = dict["userId"] as? String {
            
                if status == "accepted"{
                    
                    let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
                    let vc = st.instantiateViewController(withIdentifier: "ConfirmConntroller") as! ConfirmConntroller
                    vc.name = name
                    vc.remainingPrice = "\(remaining_price)"
                    vc.initPrice = "\(initial_Price)"
                    vc.userImage = image
                    vc.bookingID = bookingId
                    vc.serviceName = service
                    vc.serPrice = "\(service_price)"
                    vc.userID = userId
                    
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }else{
                    
                    let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
                    let vc = st.instantiateViewController(withIdentifier: "DeclinedViewController") as! DeclinedViewController
                    vc.name = name
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            
        }
      

    }
        
        
}
    
    func goToHomeScene() {
        let st:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                   let vc = st.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
                           vc.modalPresentationStyle = .fullScreen
                           self.present(vc, animated: true, completion: nil)
       
    }
    private func pushToCompleteScreen(){
//        dismiss(animated: false)
        present(storyboard!.instantiateViewController(withIdentifier: "ConfirmConntroller"), animated: true)
        
    }
    @IBAction func backClick(_ sender: Any) {
        dismiss(animated: true)
    }
}
