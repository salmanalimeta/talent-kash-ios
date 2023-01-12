//
//  ConversationVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 24/09/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase
import YPImagePicker
import SDWebImage
import Alamofire
import GrowingTextView

class ConversationVC: StatusBarController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameButton: UIButton!
    
    private var messageTxt:GrowingTextView!
//    var senderId:String = "0"
    
    var receiverId:String = "0"
    
   var name:String = ""
    
    var senderName:String = ""
    
    var dataBaseChat = Database.database().reference().child("Chat")
    var dataBaseChat2 = Database.database().reference().child("Chat")
    var childRef3 = Database.database().reference().child("Inbox")
     var childRef4 = Database.database().reference().child("Inbox")
    
    var smsArray:[Conversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.usernameButton.setTitle(self.name, for: .normal)
        senderName = UserDefaults.standard.string(forKey: "user_name") ?? "guest"
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 10
        container.layer.borderColor = UIColor.white.cgColor
        container.layer.borderWidth = 1
        container.backgroundColor = UIColor.black
        let sendImage = UIButton()
        sendImage.translatesAutoresizingMaskIntoConstraints = false
        sendImage.setImage(UIImage(named: "_Button base")!, for: .normal)
        sendImage.addTarget(self, action: #selector(self.sendmedia(_:)), for: .touchUpInside)
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(UIImage(named: "send_message")!, for: .normal)
        sendButton.addTarget(self, action: #selector(self.sendText(_:)), for: .touchUpInside)
        messageTxt = GrowingTextView()
        messageTxt.textColor = .white
        messageTxt.backgroundColor = .clear
        messageTxt.font = .systemFont(ofSize: 16)
        messageTxt.placeholder = "Type message here"
        messageTxt.placeholderColor = .lightGray
        messageTxt.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        container.addSubview(sendButton)
        container.addSubview(sendImage)
        container.addSubview(messageTxt)
        let topConstraint = messageTxt.heightAnchor.constraint(equalToConstant: 50)
               topConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            sendImage.rightAnchor.constraint(equalTo: container.rightAnchor,constant: -4),
            sendImage.bottomAnchor.constraint(equalTo: container.bottomAnchor,constant: -6),
            sendButton.rightAnchor.constraint(equalTo: sendImage.leftAnchor,constant: -4),
            sendButton.bottomAnchor.constraint(equalTo: container.bottomAnchor,constant: -6),
            
            messageTxt.leftAnchor.constraint(equalTo: container.leftAnchor),
            messageTxt.rightAnchor.constraint(equalTo: sendButton.leftAnchor,constant: -2),
            messageTxt.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            messageTxt.topAnchor.constraint(equalTo: container.topAnchor),
            topConstraint,
            
            container.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 6),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -6),
            container.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -6),
            container.heightAnchor.constraint(lessThanOrEqualToConstant: 160)
        ])
        dataBaseChat = Database.database().reference().child("Chat").child(UserDefaultManager.instance.userID+"-"+self.receiverId)
        dataBaseChat2 = Database.database().reference().child("Chat").child(self.receiverId+"-"+UserDefaultManager.instance.userID)
        
        childRef3 = Database.database().reference().child("Inbox").child(UserDefaultManager.instance.userID).child(self.receiverId)
        childRef4 = Database.database().reference().child("Inbox").child(self.receiverId).child(UserDefaultManager.instance.userID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getConversation()
    }
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -300 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func getConversation(){
        self.startPulseAnimation()
        let childRef = Database.database().reference().child("Chat").child(UserDefaultManager.instance.userID+"-"+self.receiverId).queryLimited(toLast:50)
        childRef.keepSynced(true)
        childRef.observe(.value) { (snapshot) in
            self.stopPulseAnimation()
            self.smsArray = []
            if snapshot.childrenCount > 0 {
                if snapshot.exists(){
                    for artists in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        
                        let firebaseDic = artists.value as? [String: AnyObject]
                        
                        let key1 = artists.key
                        print(key1)
                        
                        let id          = firebaseDic?["sender_id"] as? String
                        let rece_id          = firebaseDic?["receiver_id"] as? String
                        let chat_id          = firebaseDic?["chat_id"] as? String
                        let name        = firebaseDic?["sender_name"] as? String
                        let text        = firebaseDic?["text"] as? String
                        let time        = firebaseDic?["time"] as? String
                        let date        = firebaseDic?["date"] as? String
                        let image       = firebaseDic?["image"] as? String
                        let profileImage = UserDefaultManager.instance.user?.profileImage ?? ""//firebaseDic?["profile_image"] as? String
                        let type        = firebaseDic?["type"] as? String
                        
                        let messageObj = Conversation(senderId: id ?? "", receiverId: rece_id ?? "", senderName: name ?? "", message: text ?? "", date: date ?? "", time: time ?? "", type: type ?? "", image: image ?? "", profileImage: profileImage ,chatId: chat_id ?? "")
                        
                        self.smsArray.append(messageObj)
                        
                    }
              
                    self.tableView.reloadData()
                    if self.smsArray.count > 0{
                        let indexPath = NSIndexPath(row: self.smsArray.count-1, section: 0)
                        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
                }
                self.tableView.reloadData()
            }
            
            if self.smsArray.count == 0{
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                let result = formatter.string(from: date)
                let inbox = ["date":result,"text":"","receiver_id":self.receiverId,"receiver_name":self.name]
                let inbox1 = ["date":result,"text":"","receiver_id":UserDefaultManager.instance.userID,"receiver_name":self.senderName]
              
                self.childRef3.updateChildValues(inbox)
                self.childRef4.updateChildValues(inbox1)
            }
            self.tableView.reloadData()
        }
        
    }
    
//    func GetProcessMessages(){
//
//        let childRef = Database.database().reference().child("Chat").child(self.senderId+"-"+self.receiverId).queryLimited(toLast:50)
//
//        childRef.keepSynced(true)
//
//
//        childRef.observe(DataEventType.value, with: { (snapshot) in
//            self.smsArray = []
//
//            if snapshot.childrenCount > 0 {
//
//                for artists in snapshot.children.allObjects as! [DataSnapshot] {
//                    let artistObject = artists.value as? [String: AnyObject]
//                    print(artistObject!)
//
//
//                    let key1 = artists.key
//                    print(key1)
//
//                    let id          = artistObject?["sender_id"] as? String
//                    let rece_id          = artistObject?["receiver_id"] as? String
//                    let chat_id          = artistObject?["chat_id"] as? String
//                    let name        = artistObject?["sender_name"] as? String
//                    let text        = artistObject?["text"] as? String
//                    let time        = artistObject?["time"] as? String
//                    let date        = artistObject?["date"] as? String
//                    let image        = artistObject?["image"] as? String
//                    let type        = artistObject?["type"] as? String
//
//                    let messageObj = Conversation(senderId: id ?? "", receiverId: rece_id ?? "", senderName: name ?? "", message: text ?? "", date: date ?? "", time: time ?? "", type: type ?? "", image: image ?? "",chatId: chat_id ?? "")
//
//                    self.smsArray.add(messageObj)
//
//                }
//
//
//                self.tableView.reloadData()
//                DispatchQueue.main.async {
//                    if self.smsArray.count > 0{
//                        let indexPath = NSIndexPath(row: self.smsArray.count-1, section: 0)
//                        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
//                    }
//
//                }
//            }
//        })
//    }
    
    @IBAction func sendmedia(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.screens = [.library, .photo]
        config.library.mediaType = .photo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let image = items.singlePhoto {
            
                print("photo: ",image.originalImage)
                
                let number = Int.random(in: 0 ... 1000)
                let storageRef = Storage.storage().reference().child(String(number)+"_myImage.png")
     
                if let uploadData = image.originalImage.jpegData(compressionQuality: 1.0) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata,error ) in
                        guard metadata != nil else{
                            print(error!)
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        storageRef.downloadURL { (url, error) in
                            print(url!)
                            let downloadImage = String(describing: url!)
                            let key = self.dataBaseChat.childByAutoId().key
                            let date = Date()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "dd-MM-yyyy"
                            let result = formatter.string(from: date)
                            let formatter1 = DateFormatter()
                            formatter1.dateFormat = "hh:mm a"
                            let time = formatter1.string(from: date)
                            let message = ["sender_id":UserDefaultManager.instance.userID,"receiver_id":self.receiverId,"sender_name":self.senderName ,"image":downloadImage,"text":"","date":result,"time":time,"type":"photo","chat_id":key] as? [String:Any]
                         

                            self.dataBaseChat.child(key!).setValue(message)
                            self.dataBaseChat2.child(key!).setValue(message)
                            
                            let inbox = ["date":result,"text":"sent an attachment","receiver_id":self.receiverId,"receiver_name":self.name]
                            let inbox1 = ["date":result,"text":"sent an attachment","receiver_id":UserDefaultManager.instance.userID,"receiver_name":self.senderName]
                            self.chatApi(text: "sent an attachment")
                            self.childRef3.updateChildValues(inbox)
                            self.childRef4.updateChildValues(inbox1)
                            UIViewController.removeSpinner()
                            guard url != nil else {
                                return
                            }
                        }
                    })
                   
                }
            }
            picker.dismiss(animated: true) {
                UIViewController.displaySpinner(onView: self.view)
            }
        }
        present(picker, animated: true, completion: nil)
    }
    @IBAction func usernameTap(_ sender: Any) {
        let vc = UIStoryboard(name: "otherProfile", bundle: nil).instantiateViewController(withIdentifier: "OthersProfileController") as! OthersProfileController
        vc.otherUser_Id = receiverId
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func sendText(_ sender: Any) {
        
        if messageTxt.text.isEmpty == true || messageTxt.text ==  "Type message...." {
            
            self.showToast(message: "Please type any meessage...", font: UIFont.systemFont(ofSize: 12.0))
        }else{
            let key = dataBaseChat.childByAutoId().key
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let result = formatter.string(from: date)
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "hh:mm a"
            let time = formatter1.string(from: date)
            let message = ["sender_id":UserDefaultManager.instance.userID,"receiver_id":self.receiverId,"sender_name":self.senderName ,"image":"","text":self.messageTxt.text ?? "","date":result,"time":time,"type":"text","chat_id":key] as? [String:Any]
         
            
            
            dataBaseChat.child(key!).setValue(message)
            dataBaseChat2.child(key!).setValue(message)
            
            let inbox = ["date":result,"text":self.messageTxt.text ?? "","receiver_id":self.receiverId,"receiver_name":name]
            let inbox1 = ["date":result,"text":self.messageTxt.text ?? "","receiver_id":UserDefaultManager.instance.userID,"receiver_name":self.senderName]
            self.childRef3.updateChildValues(inbox)
            self.childRef4.updateChildValues(inbox1)
            self.chatApi(text: self.messageTxt.text ?? "")
            messageTxt.text = nil
          
        }
    }
    
    @objc func senderTextAction(sender: UIButton){
        let buttonTag = sender.tag
        
        let obj = self.smsArray[buttonTag] as? Conversation
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let startOver: UIAlertAction = UIAlertAction(title: "Copy", style: .default) { action -> Void in
          
            UIPasteboard.general.string = obj?.message
        }

        let discard: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { action -> Void in
     
            self.dataBaseChat.child(obj?.chatId ?? "0").removeValue()
            self.dataBaseChat2.child(obj?.chatId ?? "0").removeValue()
            self.getConversation()
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

          // add actions
        actionSheetController.addAction(startOver)
        actionSheetController.addAction(discard)
        actionSheetController.addAction(cancelAction)


        // present an actionSheet...
        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true) {
            print("option menu presented")
        }
        
    }
    
    @objc func receiverTextAction(sender: UIButton){
        let buttonTag = sender.tag
        
        let obj = self.smsArray[buttonTag] as? Conversation
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let startOver: UIAlertAction = UIAlertAction(title: "Copy", style: .default) { action -> Void in
          
            UIPasteboard.general.string = obj?.message
        }


        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

          // add actions
        actionSheetController.addAction(startOver)
        actionSheetController.addAction(cancelAction)


        // present an actionSheet...
        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
    @objc func senderImageAction(sender: UIButton){
        let buttonTag = sender.tag
        
        let obj = self.smsArray[buttonTag] as? Conversation
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let startOver: UIAlertAction = UIAlertAction(title: "Preview", style: .default) { action -> Void in
          
            let vc = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
            vc.imgUrl = obj?.image ?? ""
           
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }

        let discard: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { action -> Void in
            
            self.dataBaseChat.child(obj?.chatId ?? "0").removeValue()
            self.dataBaseChat2.child(obj?.chatId ?? "0").removeValue()
            self.getConversation()
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

          // add actions
        actionSheetController.addAction(startOver)
        actionSheetController.addAction(discard)
        actionSheetController.addAction(cancelAction)


        // present an actionSheet...
        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
    @objc func receiverImageAction(sender: UIButton){
        let buttonTag = sender.tag
        let obj = self.smsArray[buttonTag] as? Conversation
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let startOver: UIAlertAction = UIAlertAction(title: "Preview", style: .default) { action -> Void in
          
            let vc = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as? ImagePreviewViewController
            vc?.imgUrl = obj?.image ?? ""
           
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc ?? ImagePreviewViewController(), animated: true, completion: nil)
        }


        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

          // add actions
        actionSheetController.addAction(startOver)
        actionSheetController.addAction(cancelAction)


        // present an actionSheet...
        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
    func chatApi(text:String) {
        NetworkUtil.request(apiMethod: Constants.URL.sendChatNotification , parameters:["receiverId":self.receiverId,"senderId":UserDefaultManager.instance.userID,"messageBody":text], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
       
                    guard let data = data as? Data else {
                        print("cast error")
                        return
                    }
                    print("data = ",String(data: data, encoding: .utf8) ?? "no")
                    
                }) { _,error in
                    print("error--",error)
                }
    }
}
extension ConversationVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.smsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = self.smsArray[indexPath.row]
        if obj.type == "text"{
            if obj.senderId == UserDefaultManager.instance.userID{
                let cell : SenderTextCell = tableView.dequeueReusableCell(withIdentifier: "SenderTextCell", for: indexPath) as? SenderTextCell ?? SenderTextCell()
                cell.sndTxtTime.text = obj.time
                cell.snd_txt.text = obj.message
                cell.profileImageView.sd_setImage(with: URL(string: obj.profileImage ),placeholderImage: UIImage(named: "user")!)
                if indexPath.row == 0{
                    cell.dateView.alpha = 1
                    cell.btnDateSection.setTitle(Constants.getFormattedDate(string: obj.date , formatter:"dd-MM-yyyy", formatter1: "E, d MMM yyyy"), for: .normal)
                }else{
                    let obj1 = self.smsArray[indexPath.row-1]
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let firstDate = formatter.date(from: obj1.date )
                    let secondDate = formatter.date(from: obj.date  )
                    if firstDate?.compare(secondDate!) == .orderedSame {
                        cell.dateView.alpha = 0
                    }else{
                        cell.dateView.alpha = 1
                        cell.btnDateSection.setTitle(Constants.getFormattedDate(string: obj.date , formatter:"dd-MM-yyyy", formatter1: "E, d MMM yyyy"), for: .normal)
                    }
                }
                cell.btnAction.tag = indexPath.row
                cell.btnAction.addTarget(self, action: #selector(senderTextAction(sender:)), for: .touchUpInside)
                return cell
                
            }else{
                let cell : ReceiverTextCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverTextCell", for: indexPath) as? ReceiverTextCell ?? ReceiverTextCell()
                cell.recTxtTime.text = obj.time
                cell.rec_txt.text = obj.message
                if indexPath.row == 0{
                    cell.dateView.alpha = 1
                    
                    cell.btnDateSection.setTitle(Constants.getFormattedDate(string: obj.date , formatter:"dd-MM-yyyy", formatter1: "E, d MMM yyyy"), for: .normal)
                }else{
                    let obj1 = self.smsArray[indexPath.row-1]
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let firstDate = formatter.date(from: obj1.date)
                    let secondDate = formatter.date(from: obj.date)
                    
                    if firstDate?.compare(secondDate!) == .orderedSame {
                        cell.dateView.alpha = 0
                    }else{
                        cell.dateView.alpha = 1
                        cell.btnDateSection.setTitle(Constants.getFormattedDate(string: obj.date , formatter:"dd-MM-yyyy", formatter1: "E, d MMM yyyy"), for: .normal)
                    }
                }
                cell.btnAction.tag = indexPath.row
                cell.btnAction.addTarget(self, action: #selector(receiverTextAction(sender:)), for: .touchUpInside)
                
                return cell
            }
        }else{
            if obj.senderId == UserDefaultManager.instance.userID{
                let cell : SenderImageCell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                cell.sndImageTime.text = obj.time
                cell.snd_image.sd_setImage(with: URL(string: obj.image ), placeholderImage: UIImage(named: "placeholder.user"))
                cell.profileImageView.sd_setImage(with: URL(string: obj.profileImage ),placeholderImage: UIImage(named: "user")!)
                print("pfp = ",obj.profileImage)
                print("\nsnd image = ",obj.image)
                if indexPath.row == 0{
                    cell.dateView.alpha = 1
                    cell.btnDateSection.setTitle(Constants.getFormattedDate(string: obj.date , formatter:"dd-MM-yyyy", formatter1: "E, d MMM yyyy"), for: .normal)
                }else{
                    let obj1 = self.smsArray[indexPath.row-1]
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let firstDate = formatter.date(from: obj1.date)
                    let secondDate = formatter.date(from: obj.date)
                    if firstDate?.compare(secondDate!) == .orderedSame {
                        cell.dateView.alpha = 0
                    }else{
                        cell.dateView.alpha = 1
                        cell.btnDateSection.setTitle(Constants.getFormattedDate(string: obj.date, formatter:"dd-MM-yyyy", formatter1: "E, d MMM yyyy"), for: .normal)
                    }
                }
                cell.btnAction.tag = indexPath.row
                cell.btnAction.addTarget(self, action: #selector(senderImageAction(sender:)), for: .touchUpInside)
                return cell
            }else{
                let cell : ReceiverImageCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as? ReceiverImageCell ?? ReceiverImageCell()
                cell.recImageTime.text = obj.time
                cell.rec_image.sd_setImage(with: URL(string: obj.image ), placeholderImage: UIImage(named: "placeholder.user"))
                if indexPath.row == 0{
                    cell.dateView.alpha = 1
                    cell.btnDateSection.setTitle(Constants.getFormattedDate(string: obj.date , formatter:"dd-MM-yyyy", formatter1: "E, d MMM yyyy"), for: .normal)
                }else{
                    let obj1 = self.smsArray[indexPath.row-1]
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let firstDate = formatter.date(from: obj1.date)
                    let secondDate = formatter.date(from: obj.date)
                    
                    if firstDate?.compare(secondDate!) == .orderedSame {
                        cell.dateView.alpha = 0
                    }else{
                        cell.dateView.alpha = 1
                        cell.btnDateSection.setTitle(Constants.getFormattedDate(string: obj.date , formatter:"dd-MM-yyyy", formatter1: "E, d MMM yyyy"), for: .normal)
                    }
                }
                cell.btnAction.tag = indexPath.row
                cell.btnAction.addTarget(self, action: #selector(receiverImageAction(sender:)), for: .touchUpInside)
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.smsArray[indexPath.row]
        if obj.type != "text"{
            let vc = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as? ImagePreviewViewController
            vc?.imgUrl = obj.image
            
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc ?? ImagePreviewViewController(), animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = self.smsArray[indexPath.row]
        if obj.type == "text"{
            return UITableView.automaticDimension
        }else{
            return 235
        }
    }
}
