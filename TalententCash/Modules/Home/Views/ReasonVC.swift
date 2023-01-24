//
//  ReasonVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 13/10/2022.
//

import UIKit

class ReasonVC: StatusBarController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var reed_id:String = "0"
    var onReportVideo:()->Void = { }
    
    let fArray = ["Minor Safety","Dangerous acts and challenges","Suicide,self-harm,and disordered eating","Adult nudity and sexual activities","Bullying and harsment","Hateful behaviour","Voillent extremism","Spam and fake engagements","Harmful misinformation","Intelllectual property infringement","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ReasonVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
            let cell:SettingCell = self.tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingCell
            cell.seetingLabel.text = self.fArray[indexPath.row]
            return cell
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
        vc.reasonnStrng = self.fArray[indexPath.row]
        vc.reel_id = reed_id
        vc.onReportVideo = self.onReportVideo
        self.present(vc , animated: true)
    }
}

