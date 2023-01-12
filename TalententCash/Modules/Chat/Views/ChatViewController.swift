//
//  ChatViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 22/09/2022.
//

import UIKit
import Alamofire
import Firebase
import FirebaseDatabase

enum Tab:String {
    case All = "ALL"
    case Chat = "Chat"
}
class ChatViewController: StatusBarController {
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var btnActivites: UIButton!
    
    @IBOutlet weak var btnmessages: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var view_Active: UIView!
    
    @IBOutlet weak var view_Message: UIView!
    
    @IBOutlet weak var activityStack: UIStackView!
    @IBOutlet weak var activityCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var openActivityTab:Bool = false
    var type:Tab = .Chat
    
    var actArray:[Notifications] = []
    
    var inboxArray:[Inbox] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if type == .Chat{
            if inboxArray.count == 0 {
                self.getInboox()
            }
        }else{
            if actArray.isEmpty {
                self.getAllActivities()
            }
        }
        if openActivityTab{
            openActivityTab = false
            self.tabActivities(self)
            print("adjnaj kljaklsjd")
        }
    }
    
    @IBAction func onActivityClick(_ sender: UIButton) {
        let st:UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "ActivityViewController") as! ActivityViewController
        vc.activityIndex = sender.tag
        self.present(vc, animated: true)
    }
   
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @IBAction func tabActivities(_ sender: Any) {
        self.emptyLabel.isHidden = !self.actArray.isEmpty
        self.btnActivites.setTitleColor(UIColor.white, for: .normal)
        self.btnmessages.setTitleColor(UIColor.darkGray, for: .normal)
        self.view_Active.backgroundColor = UIColor(named: "buttonArcFirstColor")
  
        self.view_Message.backgroundColor = UIColor.clear
     
//        self.tableView.translatesAutoresizingMaskIntoConstraints = true
//        self.tableView.frame = CGRect(x:self.tableView.frame.origin.x, y:self.collectionView.frame.origin.y+self.collectionView.frame.size.height+30, width: self.tableView.frame.size.width, height: self.tableView.frame.size.width-100)
        
        UIView.animate(withDuration: 1) {
            self.activityCollectionViewHeightConstraint.constant = 92
            self.activityStack.isHidden = false
        }
        type = .All
        if actArray.isEmpty {
            self.inboxArray.removeAll()
            self.tableView.reloadData()
            self.getAllActivities()
        }
    }
    
    @IBAction func tabMwessages(_ sender: Any) {
        self.emptyLabel.isHidden = self.inboxArray.count != 0
        self.btnActivites.setTitleColor(UIColor.darkGray, for: .normal)
        self.btnmessages.setTitleColor(UIColor.white, for: .normal)
        self.view_Active.backgroundColor = UIColor.clear
  
        self.view_Message.backgroundColor = UIColor(named: "buttonArcFirstColor")
        //self.tableView.translatesAutoresizingMaskIntoConstraints = true
//        self.tableView.frame = CGRect(x:self.tableView.frame.origin.x, y:self.collectionView.frame.origin.y , width: self.tableView.frame.size.width, height: self.tableView.frame.size.width+100)
        
//        self.tableTop.constant =  self.tableTop.constant-60
        
        UIView.animate(withDuration: 1) {
            self.activityCollectionViewHeightConstraint.constant = 0
            self.activityStack.isHidden = true
        }
        type = .Chat
        self.actArray.removeAll()
        self.tableView.reloadData()
        self.getInboox()
    }
    
    
    func getAllActivities() {
        self.emptyLabel.isHidden = true
        self.emptyLabel.text = "No Activity Found"
        self.startPulseAnimation()
        NetworkUtil.request(dataType:ActivitiesModel.self,apiMethod: Constants.baseUrl+"notification?userId="+(UserDefaults.standard.string(forKey: "user_id") ?? "")+"&type="+type.rawValue, parameters:nil, requestType: .get, onSuccess: {data in
            self.actArray.removeAll()
            self.inboxArray = []
            self.stopPulseAnimation()
            if data.status == true{
                self.actArray =  data.notifications!
            }else{
                self.showToast(message:data.message, font: UIFont.systemFont(ofSize: 12.0))
            }
            self.tableView.reloadData()
            self.emptyLabel.isHidden = !self.actArray.isEmpty
        }) { _,error in
            self.emptyLabel.isHidden = !self.actArray.isEmpty
            self.stopPulseAnimation()
        }
    }
    
    func getInboox(){
        self.emptyLabel.isHidden = true
        self.emptyLabel.text = "No Message Found"
        self.startPulseAnimation()
        let childRef = Database.database().reference().child("Inbox").child(UserDefaultManager.instance.userID)
        
        childRef.keepSynced(true)

        childRef.observe(.value) { (snapshot) in
            self.actArray.removeAll()
            self.inboxArray = []
            self.stopPulseAnimation()
            print(snapshot.childrenCount)

            if snapshot.childrenCount > 0 {
                if snapshot.exists(){

                    for artists in snapshot.children.allObjects as! [DataSnapshot] {

                        let firebaseDic = artists.value as? [String: AnyObject]

                        let key1 = artists.key
                        print(key1)
                        let rece_id     = firebaseDic?["receiver_id"] as? String
                        let name        = firebaseDic?["receiver_name"] as? String
                        let text        = firebaseDic?["text"] as? String
                        let date        = firebaseDic?["date"] as? String

                        let messageObj = Inbox(receiverId: rece_id ?? "0", receiverName: name ?? "", message: text ?? "", date: date ?? "")
                        self.inboxArray.append(messageObj)
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    self.inboxArray = self.inboxArray.sorted(by: { item1, item2 in
                        (dateFormatter.date(from: item1.date) ?? Date()).compare((dateFormatter.date(from: item2.date) ?? Date())) == .orderedDescending
                    })
                    self.tableView.reloadData()
                }
            }
            self.emptyLabel.isHidden = self.inboxArray.count != 0
        }
   }

}
extension ChatViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == .Chat{
            return self.inboxArray.count
           
        }else{
            return self.actArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        if type == .Chat{
            let obj = self.inboxArray[indexPath.row] as? Inbox
            cell.titleLabel.text = obj?.receiverName
            cell.contentLabel.text = obj?.message
            cell.dateLabel.text = obj?.date
//            cell.userImageView.sd_setImage(with: URL(string: obj.image ?? ""), placeholderImage: UIImage(named: "placeholder.user"))
        }else{
            let obj = self.actArray[indexPath.row]
            cell.titleLabel.text = obj.name
            cell.contentLabel.text = obj.message
            cell.dateLabel.text = obj.date ?? ""
            cell.userImageView.sd_setImage(with: URL(string: obj.image ?? ""), placeholderImage: UIImage(named: "placeholder.user"))
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == .Chat{
            let obj = self.inboxArray[indexPath.row]
            let st:UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
            vc.modalPresentationStyle = .fullScreen
            vc.name = obj.receiverName
            vc.receiverId = obj.receiverId
            self.present(vc, animated: true, completion: nil)
        }else{
            let obj = self.actArray[indexPath.row]
            let st:UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
            vc.modalPresentationStyle = .fullScreen
            vc.name = obj.name ?? "guest"
            vc.receiverId = obj.otherUserId ?? "0"
            self.present(vc, animated: true, completion: nil)
        }
    }
}
