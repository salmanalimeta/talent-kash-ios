//
//  HomeVideoViewController.swift
//  MusicTok
//
//  Created by Mac on 05/08/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import Alamofire
import GSPlayer


class HomeVideoViewController: StatusBarController,videoLikeDelegate{
    
    //MARK:- Outlets
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var videoDownloadProgress: UILabel!
    @IBOutlet weak var tabStack: UIStackView!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    @IBOutlet weak var noInternetView: UIView!
    @IBOutlet weak var videoDownloadBar: UIView!
    
    @IBOutlet weak var btnTalent: ButtonGradientBackground!
    
    @IBOutlet weak var btnFun: ButtonGradientBackground!
    
    
    var userSpecificReels = false
    var selectedIndex = 0
    var userId = ""
    var videoLikeHandle:((Reel)->Void)? = nil
    
    var reels:[Reel] = []
    var fixedReels = false
    var funType:Bool = true
    private var selectedUserHiring:User!
    private var isDataLoading = false
    private var limit:String = "20"
    var page:Int = 0
    private var didEndReached = false
//    private var videoEmpty = false
//    private var isOtherController =  false             //Coming from other controller
//    private var currentIndex : IndexPath?             //Coming from other controller
    private var hideHireMeButton = true
    private var moveToIndex = false
    private var firstLoad = true
    private lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        return refreshControl
    }()
    private var videoDownloader:VideoDownloader? = nil
    override func viewDidLoad() {
        fullScreen = false
        super.viewDidLoad()
        moveToIndex = userSpecificReels && selectedIndex != 0
        self.hideHireMeButton = userSpecificReels
        self.tabStack.isHidden = userSpecificReels
        self.closeButton.isHidden = !userSpecificReels
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        videoCollectionView.isPagingEnabled = true
        videoCollectionView.setCollectionViewLayout(layout, animated: true)
        videoCollectionView.refreshControl = refresher
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopPlayers),
                                               name: Notification.Name("stopPlayers"),
                                               object: nil)
        if !userSpecificReels {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.reelupdated),
                                                   name: Notification.Name("reel_updated"),
                                                   object: nil)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        for i in self.videoCollectionView.indexPathsForVisibleItems  {
            let cell = videoCollectionView.cellForItem(at: i) as? HomeVideoCollectionViewCell
            cell?.pause()
        }
        videoDownloader?.pasue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoDownloader?.resume()
        if userSpecificReels && !reels.isEmpty{
            var list = reels.filter({$0.video != nil}).map({URL(string: $0.video!)!})
            list.remove(at: selectedIndex)
            VideoPreloadManager.shared.set(waiting:list)
            
//            if self.userSpecificReels && selectedIndex > 0{
//                videoCollectionView.scrollToItem(at: .init(row: selectedIndex, section: 0), at: .centeredVertically, animated: false)
//            }
        }
        
        if !fixedReels && !userSpecificReels && reels.isEmpty{
            self.isDataLoading = true
            self.loadVideoReels()
        }

    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("stopPlayers"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("reel_updated"), object: nil)
    }
//    @objc func handleBlockUserNotification(notification: NSNotification) {
//        print("+_+_+_+_+",notification.object)
//        guard let id = notification.object as? String,let i = self.videosMainArr.firstIndex(where:{ $0.user._id == id}) else {
//            return
//        }
//        self.videosMainArr[i].user.isBlock = true
//        self.videoCollectionView.reloadData()
//    }
    
    @objc func stopPlayers(notification: NSNotification) {
        
        let visiblePaths = self.videoCollectionView.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = videoCollectionView.cellForItem(at: i) as? HomeVideoCollectionViewCell
            cell?.pause()
        }
        self.stopPulseAnimation()
    }
    
    
    @objc func reelupdated(notification: NSNotification) {
        if  let reel = notification.object as? Reel,let index = self.reels.firstIndex(where: {$0._id == reel._id}){
            updateObj(obj: reel, index: index)
            self.videoCollectionView.reloadItems(at: [.init(row: index, section: 0)])
        }
    }
    
    @IBAction func tabTalent(_ sender: Any) {
        self.funType = false
        self.hideHireMeButton = UserDefaultManager.instance.userType == .talent
        self.btnFun.backgroundGradient = false
        self.btnTalent.backgroundGradient = true
        self.refreshData()
    }
    
    @IBAction func tabFun(_ sender: Any) {
        self.funType = true
        self.hideHireMeButton = false
        self.btnFun.backgroundGradient = true
        self.btnTalent.backgroundGradient = false
        self.refreshData()
    }
    @IBAction func closeButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func tryAgainButtonClick(_ sender: Any) {
        refreshData()
    }
    @IBAction func cancelVideoDownload(_ sender: Any) {
        videoDownloader?.cancel()
        videoDownloadBar.isHidden = true
    }
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended && !reels.isEmpty{
            self.downloadVideoToGallery()
        }
    }
    
    private func refreshData() {
        if isDataLoading {
            return
        }
        isDataLoading = true
        self.noInternetView.isHidden = true
        self.page = 0
        self.limit = "20"
        self.reels.removeAll()
        self.loadVideoReels()
        self.videoCollectionView.reloadData()
    }
    
    func openShareVideo(_ videoId:String){
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
        vc.fixedReels = true
        vc.userSpecificReels = true
        vc.selectedIndex = 0
        present(vc, animated: true) {
            self.fixedReels = false
            vc.loadVideoReel(videoId: videoId)
        }
    }
    
    func updateObj(obj: Reel, index: Int) {
        self.reels.remove(at: index)
        self.reels.insert(obj, at: index)
        if userSpecificReels {
            videoLikeHandle?(obj)
            NotificationCenter.default.post(name: Notification.Name("reel_updated"), object: obj)
        }
    }
    func deleteReel(reelId:String) {
        self.reels.removeAll(where:{$0._id == reelId})
        self.firstLoad = true
        self.videoCollectionView.reloadData()
    }
    //MARK:- API handler
    func loadVideoReel(videoId:String){
       self.startPulseAnimation()
        NetworkUtil.request(dataType:ReelResponse.self,apiMethod:Constants.URL.getSpecificReel+videoId, parameters: nil, onSuccess: {data in
            self.noInternetView.isHidden = true
            self.isDataLoading = false
            if self.reels.isEmpty {
               self.stopPulseAnimation()
                self.firstLoad = true
            }
            if data.status {
                if data.reel.isEmpty{
                    self.didEndReached = true
                }else{
                    self.page += 1
                    self.reels += data.reel
                    self.videoCollectionView.reloadData()
                }
            }else{
                self.showToast(message: data.message, font: .boldSystemFont(ofSize: 16))
            }
        }) { errorType,error in
            self.isDataLoading = false
            self.stopPulseAnimation()
            if errorType == .InternetNotAvailable && self.reels.isEmpty{
                self.noInternetView.isHidden = false
            }else{
                self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            }
        }
    }
    func loadVideoReels(){
        if reels.isEmpty {
            self.startPulseAnimation()
        }
        NetworkUtil.request(dataType:ReelResponse.self,apiMethod:Constants.URL.getReels(page: page, limit: limit, userId:self.userSpecificReels ? userId : UserDefaultManager.instance.userID, categoryId: funType ? "1" : "2",userSpecificReels: self.userSpecificReels), parameters: nil, onSuccess: {data in
            self.noInternetView.isHidden = true
            self.isDataLoading = false
            if self.reels.isEmpty {
               self.stopPulseAnimation()
                self.firstLoad = true
            }
            if data.status {
                if data.reel.isEmpty{
                    self.didEndReached = true
                }else{
                    self.page += 1
                    self.reels += data.reel
                    var list = data.reel.filter({$0.video != nil}).map({v in
                        print(v.video!)
                       return URL(string: v.video!)!
                    })
                    if self.page == 1{
                        list.remove(at: 0)
                    }
                        VideoPreloadManager.shared.set(waiting:list)
                    self.videoCollectionView.reloadData()
                }
            }else{
                self.showToast(message: data.message, font: .boldSystemFont(ofSize: 16))
            }
        }) { errorType,error in
            self.isDataLoading = false
            self.stopPulseAnimation()
            if errorType == .InternetNotAvailable && self.reels.isEmpty{
                self.noInternetView.isHidden = false
            }else{
                self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            }
        }
    }
    private func downloadVideoToGallery(){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save to Photos", style: .default,handler: { _ in
            if self.videoDownloader == nil{
                self.videoDownloader = VideoDownloader(self)
            }
            guard let i = self.videoCollectionView.indexPathsForVisibleItems.first?.row, let videoUrl = self.reels[i].video,let url = URL(string: videoUrl) else {
                return
            }
            self.videoDownloader?.download(url: url)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
}

// MARK: Video collectionViewe delegate methods
extension HomeVideoViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeVideoCollectionViewCell", for: indexPath) as! HomeVideoCollectionViewCell
        cell.configure(post: self.reels[indexPath.row])
        cell.likeBtn.tag = indexPath.row
        cell.commentBtn.tag = indexPath.row
        cell.delegate = self
        if !self.reels[indexPath.row].isService || self.hideHireMeButton {
            cell.hireMeButton.isHidden = true
            cell.hireMeButtonHeightConstraint.constant = 0
        }else{
            cell.hireMeButton.isHidden = false
            cell.hireMeButtonHeightConstraint.constant = 34
        }
        cell.hireMeTap = self.hireMeButtonTap
        cell.profileClick = self.btnprofileClick(user:)
        cell.commentButtonTap = self.commentTap(userId:commentsCount:)
        cell.reportReel.tag = indexPath.row
        cell.reportReel.addTarget(self, action: #selector(report(sender:)), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:collectionView.layer.bounds.width , height: collectionView.layer.bounds.height)
        
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? HomeVideoCollectionViewCell {
            cell.pause()
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if firstLoad{
            firstLoad = self.moveToIndex
            (cell as? HomeVideoCollectionViewCell)?.play()
        }
        if moveToIndex{
            moveToIndex = false
            collectionView.scrollToItem(at: .init(row: selectedIndex, section: 0), at: [], animated: false)
        }
        
//            else{
//            if let cell = cell as? HomeVideoCollectionViewCell {
//                cell.play()
//            }
//        }
       
        if indexPath.row == self.self.reels.count-6 && !fixedReels && !self.isDataLoading && !self.didEndReached{
            self.loadVideoReels()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageHeight = scrollView.frame.size.height
        let page = Int(floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1)
        if let cell = videoCollectionView.cellForItem(at: .init(row: page, section:  0)) as? HomeVideoCollectionViewCell {
            cell.play()
        }
        if self.refresher.isRefreshing{
            self.refresher.endRefreshing()
            if !userSpecificReels{
                self.refreshData()
            }
        }
    }
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if (videoCollectionView.contentOffset.y >= videoCollectionView.contentSize.height*0.6)
//        {
//            if !isDataLoading && !didEndReached{
//                isDataLoading = true
//                self.limit = "20"
//                self.page = 0
//                loadVideoReels()
//            }
//        }
//    }
    private func btnprofileClick (user:User) {
        if userId != UserDefaultManager.instance.userID{
            
            let vc = UIStoryboard(name: "otherProfile", bundle: nil).instantiateViewController(withIdentifier: "OthersProfileController") as! OthersProfileController
            vc.user = user
            self.present(vc, animated: true, completion: nil)
        }else{
            self.tabBarController?.selectedIndex = 3
        }
    }
    private func commentTap(userId:String,commentsCount:Int){
        if let index = self.reels.firstIndex(where: {$0._id == userId}){
            self.reels[index].comment = commentsCount
        }
    }
    private func hireMeButtonTap(user:User,reel:Reel?){
            self.selectedUserHiring = user
        self.startPulseAnimation()
            //      let obj = self.videosMainArr[cell.hireMeButton.tag]
        NetworkUtil.request(apiMethod: Constants.URL.checkAvailability+(user._id), parameters:nil, requestType: .get, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
                self.stopPulseAnimation()
                guard let data = data as? Data else {
                    print("cast error")
                    return
                }
                print("data = ",String(data: data, encoding: .utf8) ?? "no")
                do{
                    let available = try JSONDecoder().decode(OTPModel.self, from: data)
                    if available.status == true{
                        let st:UIStoryboard = UIStoryboard(name: "HireMe", bundle: nil)
                        let vc = st.instantiateViewController(withIdentifier: "HireMeController") as! HireMeController
                        UserDefaults.standard.set("+92"+("\(reel?.user.user_phone ?? 0000000)" ),forKey: "providerPhone")
                        UserDefaults.standard.set(reel?.lat, forKey: "reelLat")
                        UserDefaults.standard.set(reel?.long, forKey: "reelLong")
                        vc.sPrice = reel?.service_price
                        vc.iPrice = reel?.initial_price
                        vc.rPrice = reel?.remaining_price
                        vc.lat = Double(reel?.lat ?? "0.0")
                        vc.long = Double(reel?.long ?? "0.0")
                        vc.reel = reel
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }else{
                        self.showToast(message:available.message, font: UIFont.systemFont(ofSize: 12.0))
                    }
                } catch {
                    
                    print("error: ", error)
                }
            }) {_,error in
                self.stopPulseAnimation()
                print("error--",error)
            }
    }
    @objc func report(sender: UIButton){
        let buttonTag = sender.tag
        let obj = self.reels[buttonTag]
        let vc = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ReasonVC") as! ReasonVC
        vc.reed_id = obj._id
        vc.onReportVideo = {
            self.reels.removeAll(where: {$0._id == obj._id})
            self.firstLoad = true
            self.videoCollectionView.reloadData()
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc , animated: true)
    }
}
// MARK: Video download delegate methods
extension HomeVideoViewController:VideoDownloaderDelegagte{
    func videoDownloadStarted() {
        videoDownloadBar.isHidden = false
    }
    
    func videoDownloadProgress(progress: Int) {
        videoDownloadProgress.text = " \(progress)% downloaded"
        print(progress)
    }
    
    func videoDownloadCompleted() {
        videoDownloadBar.isHidden = true
        self.showToast(message: "Video Saved to Photos")
    }
    
    func videoDownloadBusy() {
        self.showToast(message: "Video already in progress, Try later!")
    }
    
    func videoDownloadFailed(msg: String) {
        videoDownloadBar.isHidden = true
        self.showToast(message: msg)
    }
}
