//
//  OtherProfileController.swift
//  Talent Cash
//
//  Created by Aamir on 13/10/2022.
//

import UIKit

class OthersProfileController:StatusBarController{
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coverImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var collectionVideos: UICollectionView!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var userBlockLabel: UILabel!
    @IBOutlet weak var noVideoLabel: UILabel!
    @IBOutlet weak var bgCollection: UIView!
    var otherUser_Id:String = "0"
    var user:User!
    private var reels:[Reel] = []
    private var isDataLoading = false
    private let limit = "20"
    private var page:Int = 1
    private var didEndReached = false
    private var firstLoad = true
    
//    private var noCoverPhoto = true
    private var previousScrollOffset: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionVideos.isHidden = user.isBlock
//        blockLabel.isHidden = !(user.isBlock )
        if user == nil{
            user = .init(id: otherUser_Id)
        }
        collectionVideos.delegate = self
        collectionVideos.dataSource = self
//        noVideoLabel.isHidden =  user.isBlock
        if let user = user{
            self.usernameLabel.text = "@\(self.user.username)"
            self.otherUser_Id = user._id
//            self.noCoverPhoto = user.coverImage.isEmpty
            if self.user.coverImage.isEmpty{
//                coverImageHeightConstraint.constant = 50
            }else{
                self.coverImage.sd_setImage(with: URL(string: user.coverImage)!)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad || user == nil {
            firstLoad = false
            loadUser()
        }
        if reels.isEmpty{
            loadData()
        }
    }
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if identifier == "FollowVC" {
//            return user != nil && ((sender as? UIButton)?.tag) != nil
//        }
//        return true
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "FollowVC", let vc = segue.destination as? FollowVC,let tag = (sender as? UIButton)?.tag{
//            vc.user = self.user
//            vc.selectedtTab = tag == 0 ? .Follower : .Following
//        }
//    }
    @IBAction func closeButtonTap(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func openFollowPage(_ sender: UIButton) {
        if user == nil{
            return
        }
        let vc = UIStoryboard(name: "otherProfile", bundle: nil).instantiateViewController(withIdentifier: "FollowVC") as! FollowVC
        vc.user = self.user
        vc.selectedtTab = sender.tag == 0 ? .Follower : .Following
        present(vc, animated: true)
    }
    private func loadUser(){
        startPulseAnimation()
        NetworkUtil.request(dataType: UserProfileResponse.self, apiMethod: Constants.URL.otherProfile+"?fromUserId=\(UserDefaultManager.instance.userID)&toUserId=\(self.otherUser_Id)", parameters: nil) { [self] data in
            self.stopPulseAnimation()
            self.isDataLoading = false
            if data.status {
                self.collectionVideos.isHidden = data.user.isBlock
                self.blockLabel.isHidden = !(data.user.isBlock )
                self.noVideoLabel.isHidden =  !(data.user.isBlock ) || !reels.isEmpty
                self.user = data.user
                self.otherUser_Id = user._id
                self.coverImage.sd_setImage(with: URL(string: data.user.coverImage), placeholderImage: nil)
//                coverImageHeightConstraint.constant = data.user.coverImage.isEmpty ? 0 : 200
//                self.noCoverPhoto = data.user.coverImage.isEmpty
                self.collectionVideos.reloadData()
            }else{
                self.noVideoLabel.isHidden = false
                self.showToast(message: data.message, font:  .boldSystemFont(ofSize: 16))
            }
        } onFailure: { errorType, msg in
            self.showToast(message: msg, font:  .boldSystemFont(ofSize: 16))
        }
    }
    @objc private func followTap(sender:UIButton){
        if isDataLoading{
            return
        }
        if user.isBlock {
            blockUser()
            return
        }
        self.startPulseAnimation()
        isDataLoading = true
        NetworkUtil.request(apiMethod: Constants.URL.follow, parameters: ["to":self.otherUser_Id ,"from":UserDefaultManager.instance.userID]) { data in
            self.stopPulseAnimation()
            self.isDataLoading = false
            guard let data = data as? Data else {
                return
            }
            do{
                let jo = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
                if let json = jo as? [String:Any],let status = json["status"] as? Bool, let m = json["message"] as? String,let follow = json["isFollow"] as? Bool {
                    if status{
                        self.user.isFollow = follow
                        self.user.followers += follow ? 1 : -1
                        self.collectionVideos.reloadData()
                    }else{
                        self.showToast(message: m, font: .systemFont(ofSize: 18))
                    }
                }else{
                    self.showToast(message: NetworkError.serverError.rawValue, font: .systemFont(ofSize: 18))
                }
            }catch{
                self.showToast(message: NetworkError.serverError.rawValue, font: .systemFont(ofSize: 18))
            }
        } onFailure: { t, m in
            self.isDataLoading = false
            self.stopPulseAnimation()
            self.showToast(message: m, font: .systemFont(ofSize: 18))
        }
    }
    
    @objc private func chatTap(sender:UIButton){
            let st:UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
            vc.modalPresentationStyle = .fullScreen
        vc.name = self.user.name
        vc.receiverId = self.otherUser_Id
        vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        
    }
    @objc private func blockTap(sender:UIButton){
        if isDataLoading{
            return
        }
        let vc:UserBlockAlertConroller = storyboard!.instantiateViewController(withIdentifier: "UserBlockAlertConroller") as! UserBlockAlertConroller
        vc.cancelClick = {
            vc.dismiss(animated: true)
        }
        vc.blockClick = {
            vc.dismiss(animated: true) {
                self.blockUser()
            }
        }
        present(vc, animated: true)
    }   
   
    private func blockUser(){
        self.startPulseAnimation()
        isDataLoading = true
        NetworkUtil.request(apiMethod: Constants.URL.banUser, parameters: ["to":self.otherUser_Id,"from":UserDefaultManager.instance.userID]) { data in
            self.stopPulseAnimation()
            self.isDataLoading = false
            guard let data = data as? Data else {
                return
            }
            do{
                let jo = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
                if let json = jo as? [String:Any],let status = json["status"] as? Bool, let m = json["message"] as? String, let blocked = json["isBlock"] as? Bool{
                    if status{
                        self.userBlockLabel.isHidden = !blocked
                        self.user?.isBlock = blocked
                        self.collectionVideos.reloadData()
                        if blocked{
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "UserBlockedAlertConroller") as! UserBlockedAlertConroller
                            vc.closeClick = {
                                vc.dismiss(animated: true)
                            }
                            self.present(vc, animated: true)
                        }
                    }else{
                        self.showToast(message: m, font: .systemFont(ofSize: 18))
                    }
                }else{
                    self.showToast(message: NetworkError.serverError.rawValue, font: .systemFont(ofSize: 18))
                }
            }catch{
                self.showToast(message: NetworkError.serverError.rawValue, font: .systemFont(ofSize: 18))
            }
        } onFailure: { t, m in
            self.stopPulseAnimation()
            self.isDataLoading = false
            self.showToast(message: m, font: .systemFont(ofSize: 18))
        }
    }
    private func loadData(){
        self.startPulseAnimation()
        self.isDataLoading = true
        NetworkUtil.request(dataType: ReelResponse.self, apiMethod: Constants.URL.userWiseReelAndroid+"?userId=\(self.otherUser_Id)&start=\(page)&limit=20") { data in
            self.isDataLoading = false
            self.stopPulseAnimation()
            if data.status{
                if data.reel.isEmpty{
                    self.didEndReached = true
                }else{
                    self.page += 1
                    
                    self.reels += data.reel
                    self.collectionVideos.reloadData()
                }
            }else{
                self.showToast(message:data.message)
            }
        } onFailure: { error, msg in
            self.isDataLoading = false
            self.stopPulseAnimation()
            self.showToast(message:msg)
        }
    }
}

//MARK: UICollectionView Delegate Methods
extension OthersProfileController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.user?.isBlock ?? false ? 0 : reels.count
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as! OthersProfileCollectionViewHeaderCell
        if user == nil {
            return cell
        }
       
        cell.followButton.addTarget(nil, action: #selector(followTap), for: .touchUpInside)
        cell.chatButton.addTarget(nil, action: #selector(chatTap), for: .touchUpInside)
        cell.blockButton.addTarget(nil, action: #selector(blockTap(sender:)), for: .touchUpInside)
//        cell.bookingButtonClick = self.bookingButtonClick
        cell.user = self.user
//        cell.roundCorners(corners: [.topRight,.topLeft], radius: 20)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! VideoImageCell
        cell.setupUIData(model: self.reels[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

            return  CGSize(width: size, height: size+80)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
        vc.reels = reels
        vc.userSpecificReels = true
        vc.selectedIndex = indexPath.row
        vc.videoLikeHandle = {reel in
            if let i = self.reels.firstIndex(where: {$0._id == reel._id}){
                self.reels.remove(at: i)
                self.reels.insert(reel, at: i)
                self.collectionVideos.reloadItems(at: [.init(row: i, section: 0)])
            }
        }
        UIApplication.topViewController()?.present(vc , animated: true)

    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.self.reels.count-6 && !self.isDataLoading && !self.didEndReached{
            self.loadData()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 250 {
            bgCollection.transform = .init(translationX: 0, y: -scrollView.contentOffset.y)
        }
        let scrollDiff = (scrollView.contentOffset.y - previousScrollOffset)
        print(scrollDiff)
            var newHeight = coverImageHeightConstraint.constant
            if scrollDiff > 0 {
                newHeight = max(60, coverImageHeightConstraint.constant - abs(scrollDiff))
            } else if scrollDiff < 0 {
                newHeight = min(200, coverImageHeightConstraint.constant + abs(scrollDiff))
            }
            if newHeight != coverImageHeightConstraint.constant {
                coverImageHeightConstraint.constant = newHeight
//                setScrollPosition()
                previousScrollOffset = scrollView.contentOffset.y
            }
    }
    func setScrollPosition() {
    self.collectionVideos.contentOffset = CGPoint(x:0, y: 0)
    }
}
