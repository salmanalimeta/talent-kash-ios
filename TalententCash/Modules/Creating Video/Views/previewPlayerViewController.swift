//
//  previewPlayerViewController.swift
//  TIK TIK
//
//  Created by Mac on 22/08/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import Alamofire
import GSPlayer
import DSGradientProgressView
import AVFoundation
import CoreImage


class previewPlayerViewController: StatusBarController{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var progressView: DSGradientProgressView!
    @IBOutlet weak var btnPlayImg: UIImageView!
    @IBOutlet weak var filterView: UIView!
    fileprivate var avVideoComposition: AVVideoComposition!
    fileprivate var playerItem: AVPlayerItem!
    fileprivate var video: AVURLAsset?
    fileprivate var originalImage: UIImage?
    var url:URL?
    
    var filterType:CFilter = .init(name: "", displayName: "Normal")
    var SpeedValue:Float = 1.0
    
    
    //Filters
    internal var filterIndex = 0
    internal let context = CIContext(options: nil)
    
    @IBOutlet var collectionView: UICollectionView!
    internal var image: UIImage?
    internal var smallImage: UIImage?
    var filterImages = [UIImage]()
    
    
    //MARK:-ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        //        self.collectionView.register(UINib.init(nibName: "FilterCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
      
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            let st:UIStoryboard = UIStoryboard(name: "CreatingVideo", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "FiltersViewController") as! FiltersViewController
            vc.isVideoScreen = false
        vc.applyFilter = {filter in
            self.playerView.play(for: self.url!,filterName:filter,filterIndex:0)
        }
            self.present(vc, animated: true, completion: nil)
        })
        
        DispatchQueue.main.async {
            self.playerSetup()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoPost(notification:)), name: Notification.Name("sendVideo"), object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("sendVideo"), object: nil)
        
    }
    
    
    
    //MARK:- PlayerSetup
    
    func playerSetup(){
        
        //btnPlayImg.isHidden = true
        
        playerView.play(for: url!,filterName:filterType,filterIndex:filterIndex)
        playerView.playerLayer.videoGravity = .resizeAspect
        //        playerView.playerLayer.videoGravity = .resizeAspectFill
//        playerView.playerLayer.player?.rate = SpeedValue
        self.video = AVURLAsset(url: self.url!)
        //self.image = video!.videoToUIImage()
        self.originalImage = self.image
        
        playerView.stateDidChanged = { state in
            switch state {
            case .none:
                print("none")
            case .error(let error):
                
                print("error - \(error.localizedDescription)")
                //self.progressView.wait()
                //self.progressView.isHidden = false
                
            case .loading:
                print("loading")
                //self.progressView.wait()
                // self.progressView.isHidden = false
            case .paused(let playing, let buffering):
                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
                //self.progressView.signal()
                //self.progressView.isHidden = true
            case .playing:
                //self.btnPlayImg.isHidden = true
                //self.progressView.isHidden = true
                print("playing")
            }
        }
        
        print("video Pause Reason: ",playerView.pausedReason )
    }
    
    
    @objc func gotoPost(notification: Notification) {
        
        playerView.pause(reason: .hidden)
        //        saveVideo(withURL: url!)
        let vc = storyboard?.instantiateViewController(withIdentifier: "postVC") as! postViewController
        vc.videoUrl = self.playerView.playerURL
        vc.SpeedValue = self.SpeedValue
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        print("pressed")
    }
    @IBAction func btnNext(_ sender: Any) {
        print("next pressed")
        playerView.pause(reason: .hidden)
        //        saveVideo(withURL: url!)
        let vc = storyboard?.instantiateViewController(withIdentifier: "postVC") as! postViewController
        vc.videoUrl = self.playerView.playerURL
        vc.SpeedValue = self.SpeedValue
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK:- ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.playerView.resume()
        
        //        if UserDefaults.standard.string(forKey: "uploaded") == "yes"{
        //
        //            self.dismiss(animated:true, completion: nil)
        //        }
    }
    
    //MARK:- ViewDidDisappear
    
    override func viewDidDisappear(_ animated: Bool) {
        playerView.pause(reason: .hidden)
    }
    
    
    
    
    //MARK:- API Handler
    
    //    internal func saveVideo(withURL url: URL) {
    //        let  sv = HomeViewController.displaySpinner(onView: self.view)
    //
    //        let imageData:NSData = NSData.init(contentsOf: url)!
    //
    //        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
    //        if(UserDefaults.standard.string(forKey: "sid") == nil || UserDefaults.standard.string(forKey: "sid") == ""){
    //
    //            UserDefaults.standard.set("null", forKey: "sid")
    //        }
    //
    //        let url : String = self.appDelegate.baseUrl!+self.appDelegate.uploadVideo!
    //
    //        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"videobase64":["file_data":strBase64],"sound_id":"null","description":"xyz","privacy_type":"Public","allow_comments":"true","allow_duet":"1","video_id":"009988"]
    //
    //        print(url)
    //        print(parameter!)
    //        let headers: HTTPHeaders = [
    //            "api-key": "4444-3333-2222-1111"
    //
    //        ]
    //
    //        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
    //
    //            respones in
    //
    //            switch respones.result {
    //            case .success( let value):
    //
    //                let json  = value
    //
    //                HomeViewController.removeSpinner(spinner: sv)
    //                print("json: ",json)
    //                let dic = json as! NSDictionary
    //                let code = dic["code"] as! NSString
    //                if(code == "200"){
    //                    print("Dict: ",dic)
    //                    self.dismiss(animated:true, completion: nil)
    //                }
    //            case .failure(let error):
    //                HomeViewController.removeSpinner(spinner: sv)
    //                print(error)
    //            }
    //        })
    //
    //    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        playerView.pause(reason: .hidden)
        
    }
}
