//
//  GiftSheetController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 14/09/2022.
//

import UIKit
import Alamofire

class GiftSheetController: StatusBarController {
    @IBOutlet weak var collectionViewGifts: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewGifts.delegate = self
        collectionViewGifts.dataSource = self
        
        self.getGifts()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.layer.zPosition = 0
    }
    
    @IBAction func back(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated:true, completion: nil)
    }
    
    func getGifts() {
        self.startPulseAnimation()
        NetworkUtil.request(apiMethod: Constants.URL.userGift+"?userId="+(UserDefaultManager.instance.userID) , parameters:nil, requestType: .get, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            self.stopPulseAnimation()
                    guard let data = data as? Data else {
                        print("cast error")
                        return
                    }
                    print("data = ",String(data: data, encoding: .utf8) ?? "no")
//                    do{
//                        self.userDataSource = try JSONDecoder().decode(reelCommentModel.self, from:  data)
//                        if self.userDataSource.status == true{
//
//                            self.commentsArray =  self.userDataSource.comment!
//                        }else{
//
//                            self.showToast(message:self.userDataSource.message, font: UIFont.systemFont(ofSize: 12.0))
//                        }
//
//                        self.collectionViewComments.delegate = self
//                        self.collectionViewComments.dataSource = self
//                        self.collectionViewComments.reloadData()
//
//                    } catch {
//                        print("error: ", error)
//                    }
                    
                }) { _,error in
                    self.stopPulseAnimation()
                    print("error--",error)
                }
    }
    
}

extension GiftSheetController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "giftCell", for: indexPath) as! GiftCollectionViewCell
        cell.setData()
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        .init(width: collectionView.frame.width*0.28, height: collectionView.frame.width*0.35)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.height/2, height: collectionView.frame.height/2)

    }

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.5
//    }
}
