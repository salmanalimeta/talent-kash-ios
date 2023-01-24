//
//  SettingsVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 04/10/2022.
//

import UIKit
import Alamofire

class SettingsVC: StatusBarController {
    
    
    @IBOutlet weak var appVersion: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let fArray = ["Notification","Terms Of Service","Privacy Policy","About Us","Invite Friends","Delete Account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after    loading the view.
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        self.appVersion.text = "Version "+(version ?? "1.0")
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    

    @IBAction func logOut(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "LogoutVC") as! LogoutVC
        self.present(vc , animated: true)
      
    }
}
extension SettingsVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            
            let cell:SeetingSwitchCell = self.tableView.dequeueReusableCell(withIdentifier: "SeetingSwitchCell") as! SeetingSwitchCell
            cell.settingLable.text = self.fArray[indexPath.row]
            return cell
            
        }else if indexPath.row == 1{
            
            let cell:SettingCell = self.tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingCell
            cell.seetingLabel.text = self.fArray[indexPath.row]
            return cell
            
        }else if indexPath.row == 2{
            
            let cell:SettingCell = self.tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingCell
            
            cell.seetingLabel.text = self.fArray[indexPath.row]
            return cell
            
        }else{
            
            let cell:SettingCell = self.tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingCell
            
            cell.seetingLabel.text = self.fArray[indexPath.row]
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.init(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        vc.modalPresentationStyle = .fullScreen
        if indexPath.row == 1{
            vc.myURL = "https://talentcash.pk/terms-and-conditions"
            vc.navTite = "Terms Of Service"
            self.present(vc , animated: true)
        }else if indexPath.row == 2{
            vc.myURL = "https://talentcash.pk/privacy-policy"
            vc.navTite = "Privacy Policy"
            self.present(vc , animated: true)
            
        }else if indexPath.row == 3{
            vc.myURL = "https://talentcash.pk/about-us"
            vc.navTite = "About Us"
            self.present(vc , animated: true)
        }else if indexPath.row == 4{
            if let rootViewController = UIApplication.topViewController() {
                let appUrl = "https://apps.apple.com/app/\(Bundle.main.bundleIdentifier.unsafelyUnwrapped)/id6443825045"
                print("appppp=",appUrl)
                let activityViewController = UIActivityViewController(activityItems: [appUrl], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = rootViewController.view
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        }else if indexPath.row == 5{
            let vc = storyboard?.instantiateViewController(withIdentifier: "DeleteAccountController") as! DeleteAccountController
            vc.onDeleteClick = {
                self.deleteAccount()
            }
            self.present(vc, animated: true)
        }
        
    }
    private func deleteAccount(){
        self.startPulseAnimation()
        NetworkUtil.request(apiMethod: Constants.URL.login+"/\(UserDefaultManager.instance.userID)", parameters:nil, requestType: .put, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            self.stopPulseAnimation()
              guard let data = data as? Data else {
                print("cast error")
                return
              }
              print("data = ",String(data: data, encoding: .utf8) ?? "no")
              do{
                let available = try JSONDecoder().decode(OTPModel.self, from: data)
                if available.status == true{
                    
                    let vc = UIStoryboard.init(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                    
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc , animated: true)
                }else{
                  self.showToast(message:available.message, font: UIFont.systemFont(ofSize: 12.0))
                }
              } catch {
                print("error: ", error)
              }
            }) { _,error in
                self.stopPulseAnimation()
              print("error--",error)
            }
    }
}
