//
//  ProfileViewController.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 14/09/2022.
//

import UIKit
import SDWebImage
import Alamofire
import AVKit

class ProfileViewController: StatusBarController,UIGestureRecognizerDelegate {
        //MARK:- Outlets
    
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var userHeaderName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    private var videoDataSource : UserProfileResponse? = nil
    private var reels:[Reel] = []
    private var isDataLoading = false
    private let limit = "20"
    private var page:Int = 1
    private var didEndReached = false
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.userHeaderName.text = UserDefaultManager.instance.user?.username
        self.walletButton.isHidden = UserDefaultManager.instance.userType == .user
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.6
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
    }
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let indexPath  = (self.collectionView?.indexPathForItem(at: gestureRecognizer.location(in: self.collectionView))) {
            (self.tabBarController as! CustomTabBarController).deleteReel(reelId: self.reels[indexPath.row]._id)
            let alert = UIAlertController(title: "Are you sure you want to delete?", message: nil, preferredStyle: .actionSheet)
               alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                   self.startPulseAnimation()
                   NetworkUtil.request(dataType: OTPModel.self, apiMethod: Constants.URL.reels+"/\(self.reels[indexPath.row]._id)",requestType: .delete) { data in
                       self.stopPulseAnimation()
                       if data.status{
                           let reelId = self.reels.remove(at: indexPath.row)._id
                           self.collectionView.reloadData()
                           
                       }
                       self.showToast(message: data.message)
                   } onFailure: { _, msg in
                       self.stopPulseAnimation()
                       self.showToast(message: msg)
                   }
               }))
               alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
               
               switch UIDevice.current.userInterfaceIdiom {
               case .pad:
                   alert.popoverPresentationController?.sourceView = self.view
                   alert.popoverPresentationController?.sourceRect = ( self.view as AnyObject).bounds
                   alert.popoverPresentationController?.permittedArrowDirections = .up
               default:
                   break
               }
               self.present(alert, animated: true, completion: nil)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        fetchProfile()
    }
    override func viewDidAppear(_ animated: Bool) {
        if reels.isEmpty{
            loadData()
        }
    }
    
    @IBAction func WalletButtonClick(_ sender: Any) {
    
        if UserDefaults.standard.string(forKey: "user_type") == "talent_provider"{
            
            let vc = UIStoryboard.init(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "CoinController") as! CoinController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc , animated: true)
        }else{
            
            self.present((UIStoryboard(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "CoinController")), animated: true)
        }
    }
    @IBAction func settingTab(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc , animated: true)
      }
    
    
   
    
    private func goToEditProfile() {
        let vc = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController
        
        vc?.name = self.videoDataSource?.user.name ?? ""
        vc?.userName = self.videoDataSource?.user.username ?? ""
        vc?.bio = self.videoDataSource?.user.bio ?? ""
        vc?.profileImage = self.videoDataSource?.user.profileImage ?? ""
        vc?.coverImageURL = self.videoDataSource?.user.coverImage ?? ""
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc ?? EditProfileViewController() , animated: true)
    }
    private func bookingButtonClick(){
        if UserDefaultManager.instance.userType == .talent{
                    let vc = UIStoryboard.init(name: "BookingProvider", bundle: nil).instantiateViewController(withIdentifier: "BookingProviderController") as! BookingProviderController
        
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
        
                }else{
        
                    let vc = UIStoryboard.init(name: "Booking", bundle: nil).instantiateViewController(withIdentifier: "BookingViewController") as! BookingViewController
        
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
        
                }
    }
  
    @IBAction func btnBack(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "otherUserID")
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Alert
    
    private func alertModule(title:String,msg:String){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    private func fetchProfile() {
        NetworkUtil.request(dataType:UserProfileResponse.self,apiMethod:Constants.URL.userProfile+"?userId="+(UserDefaultManager.instance.userID) , parameters: nil, requestType: .get, onSuccess: {data in
            if data.status {
                self.videoDataSource = data
                self.userHeaderName.text = self.videoDataSource?.user.username ?? ""
                self.collectionView.reloadData()
            }else{
                self.showToast(message: data.message)
            }
        }) { _,msg in
            self.showToast(message: msg)
        }
    }
    private func loadData(){
        self.startPulseAnimation()
        self.isDataLoading = true
        self.emptyLabel.isHidden = true
        NetworkUtil.request(dataType: ReelResponse.self, apiMethod: Constants.URL.userWiseReelAndroid+"?userId=\(UserDefaultManager.instance.userID)&start=\(page)&limit=20") { data in
            self.isDataLoading = false
            self.stopPulseAnimation()
            if data.status{
                if data.reel.isEmpty{
                    self.didEndReached = true
                }else{
                    self.page += 1
                    self.reels += data.reel
                    self.collectionView.reloadData()
                }
            }else{
                self.showToast(message:data.message)
            }
            self.emptyLabel.isHidden = !self.reels.isEmpty
        } onFailure: { error, msg in
            self.isDataLoading = false
            self.stopPulseAnimation()
            self.showToast(message:msg)
            self.emptyLabel.isHidden = !self.reels.isEmpty
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        reels.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as! ProfileCollectionViewHeaderCell
        cell.editProfileClick = self.goToEditProfile
        cell.bookingButtonClick = self.bookingButtonClick
        if var user = self.videoDataSource?.user{
            user._id = UserDefaultManager.instance.userID
            cell.user = user
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! VideoImageCell
        
        cell.setupUIData(model:reels[indexPath.row])
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
        vc.reels = reels
        vc.userSpecificReels = true
        vc.selectedIndex = indexPath.row
        vc.videoLikeHandle = {reel in
            if let i = self.reels.firstIndex(where: {$0._id == reel._id}){
                self.reels.remove(at: i)
                self.reels.insert(reel, at: i)
                self.collectionView.reloadItems(at: [.init(row: i, section: 0)])
            }
        }
        self.present(vc , animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.self.reels.count-6 && !self.isDataLoading && !self.didEndReached{
            self.loadData()
        }
    }
}
