//
//  CommentSheetController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 14/09/2022.
//

import UIKit
import Alamofire

class CommentSheetController: UIViewController{
    
    @IBOutlet weak var commentCounterLabel: UILabel!
    
    @IBOutlet weak var collectionViewComments: UICollectionView!
    
    @IBOutlet weak var txtComent: UITextField!
    
    private var userDataSource : reelCommentModel!
    
    private var commentsArray : [comment] = []
    
    private var firstAppear:Bool = true
    
    var reels_id:String = "0"
    var commentPosted:(Int)->Void = {_ in }
    @IBOutlet weak var sendCommentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewComments.delegate = self
        self.collectionViewComments.dataSource = self
        self.sendCommentView.alpha = UserDefaultManager.instance.user == nil ? 0 :1
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            firstAppear = false
            self.getReelComments()
        }
    }
    @IBAction func closeButtonTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func tabSend(_ sender: Any) {
        if txtComent.text?.isEmpty ?? false{
            self.showToast(message: "please enter any comments...", font: UIFont.systemFont(ofSize: 12.0))
        }else{
            let comment = txtComent.text.unsafelyUnwrapped
            txtComent.text = nil
            txtComent.resignFirstResponder()
            self.postComments(comment)
        }
    }
    func getReelComments() {
        print(Constants.URL.comments+"?reelId="+reels_id)
        print(self.reels_id)
        self.startPulseAnimation()
        NetworkUtil.request(dataType:reelCommentModel.self,apiMethod: Constants.URL.comments+"?reelId="+reels_id , parameters:nil, requestType: .get, onSuccess: {data in
            self.stopPulseAnimation()
                self.userDataSource = data
                if self.userDataSource.status{
                    self.commentsArray =  self.userDataSource.comment!
                    self.commentCounterLabel.text = "Comments (\(self.commentsArray.count))"
                }else{
                    self.showToast(message:self.userDataSource.message)
                }
                self.collectionViewComments.reloadData()
                self.commentPosted(self.commentsArray.count)
        }) { _,error in
            self.stopPulseAnimation()
            print("error--",error)
        }
    }
    
    func postComments(_ comment:String) {
        self.startPulseAnimation()
        NetworkUtil.request(apiMethod: Constants.URL.comments , parameters:["userId":UserDefaultManager.instance.userID,"reelId":reels_id,"comment":comment], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            
            guard let data = data as? Data else {
                return
            }
            print("data = ",String(data: data, encoding: .utf8) ?? "no")
            self.txtComent.text = ""
            self.getReelComments()
        }) { _,error in
            self.showToast(message: error)
        }
    }
    
    func deleteComments(commentId:String) {
        NetworkUtil.request(apiMethod: Constants.URL.comments , parameters:["commentId":commentId], requestType: .delete, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            
            guard let data = data as? Data else {
                print("cast error")
                return
            }
            print("data = ",String(data: data, encoding: .utf8) ?? "no")
            self.txtComent.text = ""
            self.getReelComments()
            
        }) { _,error in
            print("error--",error)
        }
    }
}
extension CommentSheetController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.commentsArray.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.bounds.width, height: requiredHeight(text: commentsArray[indexPath.row].comment ?? "", cellWidth:  collectionView.bounds.width*0.8)+72)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentCell", for: indexPath) as! CommentCollectionViewCell
        cell.arrComments = self.commentsArray[indexPath.item]
        return cell
    }
    func requiredHeight(text:String , cellWidth : CGFloat) -> CGFloat {
            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: cellWidth, height: .greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 14)
            label.text = text
            label.sizeToFit()
            return label.frame.height
        }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "Are you sure you want to delete?", preferredStyle: .actionSheet)
//
//        // create an action
//        let startOver: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { action -> Void in
//
//
//            self.deleteComments(commentId: self.commentsArray[indexPath.row]._id ?? "0")
//        }
//
//
//        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
//    // add actions
//        actionSheetController.addAction(startOver)
//        actionSheetController.addAction(cancelAction)
//
//
//        // present an actionSheet...
//        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad
//
//        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad
//
//        present(actionSheetController, animated: true) {
//            print("option menu presented")
//        }
//    }
}
        
