//
//  TimerViewController.swift
//  TalentCash
//
//  Created by Apple on 9/8/22.
//

import UIKit

class TimerViewController: StatusBarController {

    @IBOutlet weak var timerProgress: UISlider!
    
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var fBgView: UIView!
    
    var videolength:Int? = 0
    
    @IBOutlet weak var timeLength: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // self.fBgView.roundCorners(corners: [.topLeft, .topRight], radius: 15.0)
        
        timerProgress.value = Float(videolength ?? 0)
        timerProgress.minimumValue = 0
        timerProgress.maximumValue = Float(videolength ?? 0)
        timerProgress.setValue(Float(videolength ?? 0), animated: true)
        self.timeLength.text = "\(videolength ?? 0)s"
        
        self.timeLbl.text = "00:\(videolength ?? 0)"
        self.timerProgress.isContinuous = true
    }
    
    @IBAction func sliderMove(_ sender: UISlider) {
        self.btnSave.alpha = 1
        let currentValue = Float(sender.value)
         let valuee =  Int(currentValue)
        self.timeLbl.text = "00:\(valuee)"
        print("tt = ",valuee)
        if (valuee > 0){
            videolength = Int(valuee)
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name("addTimer"), object:nil, userInfo: ["value":videolength ?? 0])
        self.dismiss(animated: true, completion: nil)
    }
    
}
