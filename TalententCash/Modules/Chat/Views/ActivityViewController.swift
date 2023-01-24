//
//  ChatViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 22/09/2022.
//

import UIKit
import Alamofire

class ActivityViewController: StatusBarController {
    var activityIndex:Int = 0
    
    //MARK: array value are endpoints for api request
    private let apiParam:[String] = ["like","mention","follower","comment","gift"]
    private let activityTitle:[String] = ["Likes","Mentions","Followers","Comments","Gifts"]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var activityTitleLabel: UILabel!
    
    private var actArray:[Notifications] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityTitleLabel.text = activityTitle[activityIndex]
        self.tableView.rowHeight  = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllActivities()
    }
    func getAllActivities() {
        self.startPulseAnimation()
        self.emptyLabel.isHidden = true
        self.emptyLabel.text = "No \(activityTitle[activityIndex]) Found"
        NetworkUtil.request(dataType:ActivitiesModel.self,apiMethod:Constants.URL.notifications(type: apiParam[activityIndex]), parameters:nil, requestType: .get,onSuccess: {data in
            self.stopPulseAnimation()
            if data.status == true{
                self.actArray =  data.notifications!
            }else{
                self.showToast(message:data.message)
            }
            self.tableView.reloadData()
            self.emptyLabel.isHidden = !self.actArray.isEmpty
        }) { _,error in
            self.emptyLabel.isHidden = !self.actArray.isEmpty
            self.stopPulseAnimation()
//            self.showToast(message: error)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ActivityViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        let obj = self.actArray[indexPath.row]
        cell.titleLabel.text = obj.name
        cell.contentLabel.text = (obj.message ?? "")
        cell.dateLabel.text = obj.date ?? ""
        cell.userImageView.sd_setImage(with: URL(string: obj.image ?? ""), placeholderImage: UIImage(named: "placeholder.user"))
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let obj = self.actArray[indexPath.row]
//         let st:UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
//         let vc = st.instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
//         vc.modalPresentationStyle = .fullScreen
//         vc.name = obj.name ?? "guest"
//         vc.receiverId = obj.otherUserId ?? "0"
//         self.present(vc, animated: true, completion: nil)
//    }
}
