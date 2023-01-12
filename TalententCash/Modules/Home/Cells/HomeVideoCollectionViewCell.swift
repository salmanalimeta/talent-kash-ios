//
//  HomeVideoCollectionViewCell.swift
//  MusicTok
//
//  Created by Mac on 06/08/2021.
//  Copyright © 2021 MAC. All rights reserved.
//



import UIKit
import AVFoundation
import GSPlayer
import MarqueeLabel
import DSGradientProgressView
import SDWebImage
import Alamofire
import ActiveLabel

protocol videoLikeDelegate: AnyObject {
    func updateObj(obj: Reel , index: Int)
}

class HomeVideoCollectionViewCell: UICollectionViewCell {
  
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileImageContainer: Gradient!
    //    @IBOutlet weak var giftButton: UIButton!
//    @IBOutlet weak var giftCounter: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var progressView: DSGradientProgressView!
    @IBOutlet weak var nameBtn: UILabel!
    @IBOutlet weak var musicLbl: MarqueeLabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var musicBtn: UIButton!
    @IBOutlet weak var pauseImgView: UIImageView!
    @IBOutlet weak var hireMeButton: UIButton!
    @IBOutlet weak var hashTagLabel: ActiveLabel!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var reportReel: UIButton!
    @IBOutlet weak var hireMeButtonHeightConstraint: NSLayoutConstraint!
    private var isPlaying = false
    private(set) var liked = false
    private(set) var liked_count:Int!
    
    var reel :Reel?
//    var delegateHomeVideoVC:HomeVideoViewController!
    var delegate:HomeVideoViewController!
    var hireMeTap:(User,Reel?)->(Void) = {_,_ in }
    var profileClick:(User)->(Void) = {_ in }
    var commentButtonTap:(String,Int)->(Void) = {_,_ in }
    // MARK: Lifecycles
    
    //MARK:- awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("commentVideo"), object: nil)
        self.setupView()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("commentVideo"), object: nil)
    }
    
    //MARK:- SetupView
    func setupView(){
        pauseImgView.isHidden = true
//        self.imgMusicBtn.makeRounded()
        self.musicBtn.makeRounded()
        self.videoPlayer()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        playerView.isUserInteractionEnabled = true
        self.playerView.addGestureRecognizer(tap)
        
        if #unavailable(iOS 15.0) {
            likeBtn.alignImageTop(spacing: 4,paddingBttom: 15)
            commentBtn.alignImageTop(spacing: 4,paddingBttom: 15)
            shareBtn.alignImageTop(spacing: 4,paddingBttom: 15)
            reportReel.alignImageTop(spacing: 4,paddingBttom: 15)
        }
        likeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        commentBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        shareBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        reportReel.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        captionLabel.enabledTypes = [.mention,.hashtag]
    }

    //MARK:- Configuration
    
    func configure(post: Reel){
        self.reel = post
        self.nameBtn.text =  post.user.name
        self.nameBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.OnUserImageTap)))
        
        let userImgPath = AppUtility?.detectURL(ipString: post.user.profileImage)
        let userImgUrl = URL(string: userImgPath!)
        self.profileImageView.sd_setImage(with: userImgUrl, placeholderImage: UIImage(named: "placeholder.user"))
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.OnUserImageTap)))
//        self.musicBtn.layer.cornerRadius = 0.5 * self.musicBtn.bounds.size.width
//        self.musicBtn.clipsToBounds = true
        self.musicBtn.setImage(UIImage(named: "soundRound"), for: .normal)
        
        self.captionLabel.customize { label in
            label.text = post.caption
        }
        self.hashTagLabel.text = post.hashtag?.first?.isEmpty ?? true ? "" : post.hashtag?.reduce(into: "", { $0 += "#\($1) " })
        self.musicLbl.text = post.song?.title.isEmpty ?? true ? "Original Sound" : post.song?.title
        self.likeBtn.setTitle("\(post.like)", for: .normal)
        self.commentBtn.setTitle("\(post.comment)", for: .normal)
        self.liked_count = Int(post.like)
        
        likeBtn.setImage(UIImage(named: "like")!, for: .normal)
        likeBtn.setImage(UIImage(named: "liked")!, for: .selected)
        liked = post.isLike
        likeBtn.isSelected = post.isLike
        
        self.pauseImgView.image = .init(named: "play")
        self.pauseImgView.isHidden = true
        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? AppDelegate()
       // let localURL = appDelegate.getLocalVideoData(remoteUrl: post.video ?? "")
//        if localURL != ""  {
//            playerView.load(for: URL(string:localURL)!)
//        }else{
            //appDelegate.saveVideoIntoDoca(remoteUrl: post.video ?? "")
            playerView.load(for: URL(string:post.video ?? "")!)
       // }
        
        profileImageContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OnUserImageTap)))
        
        if #unavailable(iOS 15.0) {
            likeBtn.alignImageTop(spacing: 4,paddingBttom: 15)
        }
    }
    @objc func OnUserImageTap(sender:UITapGestureRecognizer){
        btnprofile(sender)
    }

    func play() {
        musicLbl.holdScrolling = false
        playerView.play()
//        playerView.playerLayer.player?.rate = Float(self.reel?.speed ?? "1") ?? 1.0
        playerView.isHidden = false
        isPlaying =  true
    }
    
    func pause(){
        isPlaying =  false
        playerView.pause(reason: .hidden)
        musicLbl.holdScrolling = true
    }
    
    @objc func handleSingleTap(_ gesture: UITapGestureRecognizer){
        if self.playerView.state == .playing {
            self.playerView.pause(reason: .userInteraction)
        } else {
            self.playerView.resume()
        }
    }
    func videoPlayer(){
        playerView.stateDidChanged = { state in
            switch state {
            case .none:
                print("none")
            case .error(let error):
                print("error - \(error.localizedDescription)")
                self.progressView.wait()
                self.progressView.isHidden = true
            case .loading:
//                print("loading")
                self.progressView.wait()
                self.progressView.isHidden = false
            case .paused(_, _):
                self.progressView.signal()
//                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
                self.pauseImgView.isHidden = !self.isPlaying
                self.musicBtn.stopRotating()
            case .playing:
                self.pauseImgView.isHidden = true
                self.progressView.isHidden = true
                self.musicBtn.startRotating()
            }
        }
    }
    // MARK: - Button Actions
    
    @IBAction func like(_ sender: UIButton) {
        //        if sender.tintColor == .red {
        //            sender.tintColor = .white
        //            return
        //        }
        UIView.animate(withDuration: 0.2) {
            sender.transform = CGAffineTransform(scaleX: 0.4, y: 0.6)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                sender.transform = CGAffineTransform.identity
            }
        }
        btnLike(senderTag:sender.tag)
    }
    
    func btnLike(senderTag:Int){
        self.likeDislike()
        self.liked.toggle()
        likeBtn.isSelected = self.liked
        liked_count = self.liked ? liked_count + 1 : liked_count - 1
        self.likeBtn.setTitle("\(liked_count!)", for: .normal)
        
        self.reel?.like  = liked_count
        self.reel?.isLike  = self.liked
        
        delegate.updateObj(obj: self.reel!, index: senderTag)
    }
    
    func likeDislike() {
        NetworkUtil.request(apiMethod: Constants.URL.like , parameters:["reelId":reel?._id ?? "0","userId":UserDefaultManager.instance.userID], requestType: .post, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            guard let data = data as? Data else {
                print("cast error")
                return
            }
            print("data = ",String(data: data, encoding: .utf8) ?? "no")
            
        }) { _,error in
            print("error--",error)
        }
    }
    @IBAction func hireMeButtoClick(_ sender: UIButton) {
        guard let user = self.reel?.user else {
            return
        }
        self.hireMeTap(user,self.reel)
    }
    
    @objc func btnprofile (_ sender: AnyObject) {
        self.playerView.pause(reason: .userInteraction)
        if let user = self.reel?.user{
            profileClick(user)
        }
    }
    
    @IBAction func comment(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "CommentSheetController") as! CommentSheetController
        if #available(iOS 15.0, *) {
            (vc.presentationController as? UISheetPresentationController)?.detents = [.medium(),.large()]
        }
        vc.reels_id = self.reel?._id ?? ""
        vc.commentPosted = {commentsCount in
            self.commentBtn.setTitle("\(commentsCount)", for: .normal)
            self.commentButtonTap(self.reel?._id ?? "",commentsCount)
            self.reel?.comment = commentsCount
            self.delegate.updateObj(obj: self.reel!, index: sender.tag)
        }
        UIApplication.topViewController()?.present(vc, animated: true)
    }
    
    @IBAction func share(_ sender: Any) {
       if let rootViewController = UIApplication.topViewController() {
           let activityViewController = UIActivityViewController(activityItems:  [URL(string: Constants.baseUrl+"video/"+self.reel!._id).unsafelyUnwrapped], applicationActivities: [])
//           let activityViewController = UIActivityViewController(activityItems:  ["deeplink://talentcash.pk/video/"+self.reel!._id], applicationActivities: [])
           activityViewController.popoverPresentationController?.sourceView = rootViewController.view
           rootViewController.present(activityViewController, animated: true, completion: nil)
       }
    }

    @objc func methodOfReceivedNotification(notification: Notification) {
        let notif = notification.object as! [String:Any]
        var obj = self.reel
        var comentCount:Int =  notif["Count"] as! Int
        comentCount = comentCount + 1
        obj?.comment = comentCount
        self.commentBtn.setTitle("\(comentCount)", for: .normal)
//        delegate?.updateObj(obj: obj!, index:  notif["SelectedIndex"] as! Int, islike: false)
    }
}
extension UIView {
    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    func startRotating(duration: Double = 3) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(Double.pi * 2.0)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}

extension UITextView {
       func numberOfLines(textView: UITextView) -> Int {
        let layoutManager = textView.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
}
