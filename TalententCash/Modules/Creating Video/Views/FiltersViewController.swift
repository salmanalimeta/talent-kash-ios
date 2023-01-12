//
//  previewPlayerViewController.swift
//  TIK TIK
//
//  Created by Mac on 22/08/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import CoreImage
import GSPlayer

class FiltersViewController: StatusBarController{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPlayImg: UIImageView!
    @IBOutlet weak var filterView: UIView!
    fileprivate var avVideoComposition: AVVideoComposition!
    fileprivate var playerItem: AVPlayerItem!
    fileprivate var video: AVURLAsset?
    fileprivate var originalImage: UIImage?
    var url:URL?
    var isVideoScreen:Bool = true
    var applyFilter:(CFilter)->Void = {_ in }
    @IBOutlet weak var btnYes: UIButton!
    
    @IBOutlet weak var fBgView: UIView!
    //Filters
    internal var filterIndex = 0
    internal let context = CIContext(options: nil)
    
    @IBOutlet var collectionView: UICollectionView!
    internal var image: UIImage?
    internal var smallImage: UIImage?
    
    //MARK:-ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        self.collectionView.register(UINib.init(nibName: "FilterCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
        //collectionView.allowsMultipleSelection = true
        self.collectionView.reloadData()
        
        if isVideoScreen == true{
            
            self.btnYes.alpha = 0
        }else{
    
            self.btnYes.alpha = 1
        }
        
       // self.fBgView.roundCorners(corners: [.topLeft, .topRight], radius: 15.0)
    
}
    
    //MARK:- PlayerSetup
    
//    func playerSetup(){
//
//        btnPlayImg.isHidden = true
//
//        playerView.contentMode = .scaleAspectFill
//        playerView.play(for: url!,filterName:"",filterIndex:0)
//
//        self.video = AVURLAsset(url: self.url!)
//        self.image = video!.videoToUIImage()
//        self.originalImage = self.image
//
//        playerView.stateDidChanged = { [self] state in
//            switch state {
//            case .none:
//                print("none")
//            case .error(let error):
//
//                print("error - \(error.localizedDescription)")
//                self.progressView.wait()
//                self.progressView.isHidden = false
//
//            case .loading:
//                print("loading")
//                self.progressView.wait()
//                self.progressView.isHidden = false
//            case .paused(let playing, let buffering):
//                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
//                self.progressView.signal()
//                self.progressView.isHidden = true
//            case .playing:
//                self.btnPlayImg.isHidden = true
//                self.progressView.isHidden = true
//                print("playing")
//            }
//        }
//
//        print("video Pause Reason: ",playerView.pausedReason )
//
//
//    }
    
    //MARK:- Button Actions
    
    @IBAction func Send(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("sendVideo"), object:nil, userInfo: nil)
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
       // delegate?.cancelButtonPressed()
        
        print("pressed")
    }
//    @IBAction func btnNext(_ sender: Any) {
//        print("next pressed")
//        playerView.pause(reason: .hidden)
//        //        saveVideo(withURL: url!)
//        let vc = storyboard?.instantiateViewController(withIdentifier: "postVC") as! postViewController
//        vc.videoUrl = self.playerView.playerURL
//        vc.modalPresentationStyle = .fullScreen
//        UserDefaults.standard.set("Public", forKey: "privOpt")
//
//        self.present(vc, animated: true, completion: nil)
//    }
//
    //MARK:- ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.playerView.resume()
    }
    
    //MARK:- ViewDidDisappear
    
    override func viewDidDisappear(_ animated: Bool) {
       // playerView.pause(reason: .hidden)
    }
    
    
    //MARK:- Functions
//    func playerReady(_ player: Player) {
//        print("playerReady")
//
//    }
    

    
    
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

        //playerView.pause(reason: .hidden)
        
    }
}


//MARK:- CollectionView
extension FiltersViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
     func createFilteredImage(filterName: CFilter, image: UIImage) -> UIImage {
         if(filterName.name == Constants.filterList[0].name ){
            return image
        }
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
         guard let filter = CIFilter(name: filterName.name) else {
             return image
         }
        filter.setDefaults()
         let s = image.size
         filterName.inputs.forEach { (k,v) in
             filter.setValue(v, forKey: k)
         }
         if filterName.name.contains("Distortion"){
             filter.setValue(CIVector(x: s.width*0.4, y:  s.height*0.4), forKey: "inputCenter")
             filter.setValue(s.width*0.4, forKey: "inputRadius")
         }
         if filterName.name.contains("ZoomBlur"){
             filter.setValue(CIVector(x: s.width*0.45, y:  s.height*0.4), forKey: "inputCenter")
             filter.setValue(10, forKey: "inputAmount")
         }
         
        // 3 - set source image
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
         let outputCGImage = context.createCGImage((filter.outputImage!), from: (filter.outputImage!.extent))
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!, scale: image.scale, orientation: image.imageOrientation)
        
        return filteredImage
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.filterList.count
   }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        
        let filterName = Constants.filterList[indexPath.row]
        cell.filterNameLabel.text = filterName.displayName
        let image = UIImage(named: "v3")!
        
        if let filter = CIFilter(name: filterName.name){
            filter.setDefaults()
            filterName.inputs.forEach { (k,v) in
                filter.setValue(v, forKey: k)
            }
            if filterName.name.contains("Distortion"){
                filter.setValue(CIVector(x: collectionView.frame.height/1.4, y:collectionView.frame.height/1.4), forKey: "inputCenter")
                filter.setValue(collectionView.frame.height/2, forKey: "inputRadius")
            }
            if filterName.name.contains("ZoomBlur"){
                filter.setValue(CIVector(x: collectionView.frame.height/2, y:  collectionView.frame.height/2), forKey: "inputCenter")
                filter.setValue(10, forKey: "inputAmount")
            }
            
            filter.setValue(CIImage(image:image), forKey: kCIInputImageKey)
            let outputCGImage = CIContext().createCGImage((filter.outputImage!), from: (filter.outputImage!.extent))
            
            cell.imageView.image = UIImage(cgImage: outputCGImage!, scale: image.scale, orientation: image.imageOrientation)
        }else{
            cell.imageView.image = image
        }
        cell.tickImg.isHidden = !(indexPath.row == self.filterIndex)
        return cell
    }
    
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         if filterIndex == indexPath.row{
             return
         }
         self.filterIndex = indexPath.row
         if isVideoScreen == true{
             NotificationCenter.default.post(name: Notification.Name("addFilter"), object:nil, userInfo: ["filterName":Constants.filterList[indexPath.row].name,"filterIndex":indexPath.row,"filterType":Constants.filterList[indexPath.row].name])
         }else{
             self.applyFilter(Constants.filterList[indexPath.row])
         }
         self.collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:120, height: 140)
    }
}
