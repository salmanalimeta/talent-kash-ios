//
//  actionMediaViewController.swift
//  TIK TIK
//
//  Created by Mac on 19/08/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MarqueeLabel
import KYShutterButton
import YPImagePicker
import GTProgressBar
import GSPlayer

class actionMediaViewController: StatusBarController,UIActionSheetDelegate {
//    MARK:- OUTLETS
//    @IBOutlet weak var filterimage: UIImageView!
    @IBOutlet weak var speedSegment: UISegmentedControl!
    @IBOutlet weak var durationSegment: UISegmentedControl!
    @IBOutlet weak var camSettingsView: UIView!
    @IBOutlet weak var btnRecordAni: KYShutterButton!
   
    @IBOutlet weak var progressViewOutlet: UIView!
//     @IBOutlet weak var masterViewOutlet: UIView!
    
//    @IBOutlet weak var previewDoneBtnsViewOutlet: UIView!
    @IBOutlet weak var galleryIconView: UIView!
    
//    @IBOutlet weak var videoViewOutlet: UIView!
    
//    @IBOutlet weak var soundsViewOutlet: UIView!
    @IBOutlet weak var soundsLabel: MarqueeLabel!

    @IBOutlet weak var speedViewOutlet: UIView!
    @IBOutlet weak var filterViewOutlet: UIView!
    @IBOutlet weak var filterViewConstainer: UIView!
    @IBOutlet weak var timerViewOutlet: UIView!
    @IBOutlet weak var videoDoneButton: UIButton!
    @IBOutlet weak var videoCancelButton: UIButton!
    
//    @IBOutlet weak var btnViewAni: UIView!
    
    @IBOutlet weak var recordViewOutlet: UIView!
    
    @IBOutlet weak var speedIconImgView: UIImageView!
    @IBOutlet weak var filterIconImgView: UIImageView!
    @IBOutlet weak var timerIconImgView: UIImageView!
    @IBOutlet weak var flashIconImgView: UIImageView!
    
    @IBOutlet weak var recordIconImgView: UIImageView!
    
    @IBOutlet weak var closeVC: UIButton!
    
    @IBOutlet var collectionView: UICollectionView!
    
//    @IBOutlet weak var masterViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var masterCenterYconstraint: NSLayoutConstraint!

    internal var flipDoubleTapGestureRecognizer: UITapGestureRecognizer?
    internal var singleTapRecord: UITapGestureRecognizer?

    
    @IBOutlet var previewView: CameraControllerView!
    
    private var audioPlayer : AVAudioPlayer?
    
    private var speedToggleState = 1
    
    private var camType = "back"
//    fileprivate var player = Player()
    
     @IBOutlet weak var progressBar: GTProgressBar!
    
    private var videoLengthSec:Double = 15.0
    private var videoRecordedSec:Double = 0.0
    private var filterType:CFilter = .init(name: "", displayName: "Normal")
    private var filterIndex = 0
    private var videoSpeed = 1.0
    private var songURL:URL!
    private var videoUrl:URL? = nil
    
    private var timer = Timer()
    private var photosLisimitedAcces = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterViewConstainer.roundCorners(corners: [.topRight,.topLeft], radius: 16)
        self.collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        self.collectionView.register(UINib.init(nibName: "FilterCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
        previewView.viedoCameraDelegate = self
        UserDefaults.standard.set("", forKey: "song_id")
        let gradientLayer:CAGradientLayer = CAGradientLayer()
           gradientLayer.frame.size = btnRecordAni.frame.size
           gradientLayer.colors =
               [[UIColor(named: "ButtonGradientEnd") ?? UIColor.init(red:176/255, green: 56/255, blue: 205/255, alpha: 1.0),UIColor(named: "ButtonGradientStart") ?? UIColor.init(red:218/255, green: 56/255, blue: 106/255, alpha: 1.0)]]
           //Use diffrent colors
        self.btnRecordAni.layer.addSublayer(gradientLayer)
        
        self.progressBar.progress = 0
        
//        UserDefaults.standard.set("nil", forKey: "url")
        
       // previewDoneBtnsViewOutlet.isHidden = true
        galleryIconView.isHidden = false
        
       // previewDoneBtnsViewOutlet.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        devicesChecks()
        tapGesturesToViews()
        if UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear){
            previewView.loadCamera()
        }
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("addFilter"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.timerAdd(notification:)), name: Notification.Name("addTimer"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.songAdded(notification:)), name: Notification.Name("songAdded"), object: nil)
        speedSegment.selectedSegmentIndex = 2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.selectItem(at: .init(row: 0, section: 0), animated: false, scrollPosition: .left)
        UserDefaults.standard.set("", forKey: "songURL")
        UserDefaults.standard.set("", forKey: "songName")
        UserDefaults.standard.set(UserDefaults.standard.string(forKey: "song_id") ?? "", forKey: "selecedSongID")
        UserDefaults.standard.set("", forKey: "song_id")
        NotificationCenter.default.post(name: Notification.Name("stopPlayers"), object:nil, userInfo: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear){
            previewView.stopCamera()
        }
        audioPlayer?.pause()
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear){
            previewView.startCamera()
        }
        devicesChecks()
        self.audioPlayer?.stop()
        self.audioPlayer?.pause()
        self.previewView.toggleFiltering(index: self.filterIndex)
        loadAudio()
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        previewView.viewWillTransition(to: size, with: coordinator)
    }
    
   
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("songAdded"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("addFilter"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("addTimer"), object: nil)
    }

//    MARK:- GESTURES ON VIEWS
    private func tapGesturesToViews(){

        let speedViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.speedViewAction))
        self.speedViewOutlet.addGestureRecognizer(speedViewgesture)
        
        let filterViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.filterViewAction))
        self.filterViewOutlet.addGestureRecognizer(filterViewgesture)
        
        let timerViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.timerViewAction))
        self.timerViewOutlet.addGestureRecognizer(timerViewgesture)
    
        let recordViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.recordViewAction))
        self.recordViewOutlet.addGestureRecognizer(recordViewgesture)
        
//        soundsViewOutlet.isUserInteractionEnabled = true
//        let soundsViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.soundsViewAction))
//        self.soundsViewOutlet.addGestureRecognizer(soundsViewgesture)
  
        galleryIconView.isUserInteractionEnabled = true
        let uploadViewgesture = UITapGestureRecognizer(target: self, action:  #selector(self.uploadViewAction))
        self.galleryIconView.addGestureRecognizer(uploadViewgesture)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        if let index = notification.userInfo?["filterIndex"] as? Int {
            self.previewView.toggleFiltering(index: index)
            self.filterIndex = index
         }
    }
    
    @objc func songAdded(notification: Notification) {
        
        print(notification.userInfo ?? "")
        if let song_id = notification.userInfo?["song_id"] as? String {
            
            UserDefaults.standard.set(song_id, forKey: "song_id")
         }
    }
    
    @objc func timerAdd(notification: Notification) {
        if let name = notification.userInfo?["value"] as? Int {
            self.videoLengthSec = Double(name)
         }
    }
    @IBAction func closeFilterClick(_ sender: Any) {
        self.filterViewConstainer.isHidden.toggle()
    }
    @IBAction func speedCalculation(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.videoSpeed = 2
        }

        if sender.selectedSegmentIndex == 1 {
            print("Sometimes ")
            self.videoSpeed = 1.5

        }
        if sender.selectedSegmentIndex == 2 {
            print("Yes")
            self.videoSpeed = 1.0
        }

        if sender.selectedSegmentIndex == 3 {
            print("Yes")
            self.videoSpeed = 0.6
        }
        if sender.selectedSegmentIndex == 4 {
            self.videoSpeed = 0.4
        }
    }
    @IBAction func durationChanged(_ sender: UISegmentedControl) {
        self.videoLengthSec = Double(sender.selectedSegmentIndex == 0 ? 15 : sender.selectedSegmentIndex == 1 ? 30 : 60)
//        NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTimeMakeWithSeconds(videoLengthSec, preferredTimescale: 600)
    }
    
    @objc func speedViewAction(sender : UITapGestureRecognizer) {
        print("speedView tapped")
//        generalBtnAni(viewName: speedIconImgView)
        self.speedSegment.isHidden.toggle()
    }
    
    @objc func filterViewAction(sender : UITapGestureRecognizer) {
        print("filterView tapped")
       // generalBtnAni(viewName: filterIconImgView)
        self.filterViewConstainer.isHidden.toggle()
    }
    
  
    
    @objc func timerViewAction(sender : UITapGestureRecognizer) {
        print("timerView tapped")
        //generalBtnAni(viewName: timerIconImgView)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TimerViewController") as! TimerViewController
        vc.videolength = Int(videoLengthSec)
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func recordViewAction(sender : UITapGestureRecognizer) {
        print("recordView tapped")
        UIView.animate(withDuration: 0.6,
        animations: {
            self.recordIconImgView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.recordIconImgView.layer.cornerRadius = 6
        },
        completion: { _ in
            print("done")
        })
    }
    
//    MARK: - ANIMATION
//    func generalBtnAni(viewName:UIImageView)
//    {
//        UIView.animate(withDuration: 0.2,
//        animations: {
//            viewName.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//            viewName.layer.cornerRadius = 6
//        },
//        completion: { _ in
//            UIView.animate(withDuration: 0.2) {
//                viewName.transform = CGAffineTransform.identity
//            }
//        })
//    }
    
//    MARK:- DEVICE CHECKS
    func devicesChecks(){
        if DeviceType.iPhoneWithHomeButton{
            UIApplication.shared.isStatusBarHidden = true
        }
    }

//    MARK:- LOAD AUDIO
    func loadAudio(){
        if let destinationUrl = UserDefaults.standard.url(forKey: "songURL") {
            print("destinationUrl: ",destinationUrl)
            self.songURL = destinationUrl
//            audioPlayer?.rate = 1.0;
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                print("loaded audio file")

                let soundName = UserDefaults.standard.string(forKey: "songName")

                soundsLabel.text = soundName
                soundsLabel.type = .continuous

            } catch {
                print("CouldNot load audio file")
            }
        }
    }
    
    private func openAlertForPermission(forVideo:Bool){
        let ac = UIAlertController(title: "Permission Denied", message: "Talent Cash doesn't have authorization for \(forVideo ? "VIDEO" : "AUDIO"). For creating video authorize \(forVideo ? "VIDEO" : "AUDIO") permission by tapping 'Open Setting'", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Close", style: .destructive,handler: { _ in
            self.dismiss(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Grant Permission", style: .default,handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        self.present(ac, animated: true)
    }
    @IBAction func btnDone(_ sender: Any) {
         self.previewView._captureState = .end
    }
    @IBAction func btnCloseSession(_ sender: Any) {
        self.btnRecordAni.buttonState = .normal
        self.previewView._captureState = .cancel
        if let url = videoUrl {
            try? FileManager.default.removeItem(at: url)
            self.videoUrl = nil
        }
    }
    
    func sessionDoneFunc(url:URL?) {
        self.camSettingsView.isHidden = false
        guard let url = url else {
            self.showToast(message: "Video Recording Faild With Unkown Error!")
            return
        }
        self.startPulseAnimation()
        self.mergeVideoWithAudio(videoUrl: url, audioUrl: self.songURL, success: { (url) in
            DispatchQueue.main.async {
                self.stopPulseAnimation()
                //                    let attribute = try! FileManager.default.attributesOfItem(atPath:url.path)
                //                    if let size = attribute[FileAttributeKey.size] as? NSNumber {
                //                        let sizeInMB = size.doubleValue / 1000000.0
                //                        print("camera sizeInMB=",sizeInMB)
                //                    }
                let vc =  self.storyboard?.instantiateViewController(withIdentifier: "previewPlayerVC") as! previewPlayerViewController
                vc.url = url
                vc.SpeedValue = 1 //Float(self.videoSpeed )
                vc.filterIndex = self.filterIndex
                vc.filterType = self.filterType
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }, failure: { (error) in
            print("Error to merge audio and video")
        })
    }
}

// MARK: - Camera Video Delegate Methods

extension actionMediaViewController:CameraDelegate {
    func permissionDenied() {
        self.dismiss(animated: true)
    }
    func permissionDenied(video: Bool, audio: Bool) {
        let alert = UIAlertController(title: "\(video ? "VIDEO " : "")\(video && audio ? " & " : "")\(audio ? "AUDIO " : "")Persmission Denied!", message: "Tap 'Open Settings' to grant \(video ? "VIDEO " : "")\(video && audio ? " & " : "")\(audio ? "AUDIO " : "") access", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Exit", style: .default,handler: { _ in
            self.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default,handler: { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
               UIApplication.shared.open(settingsUrl)
             }
        }))
        
        present(alert, animated: true)
    }
    
    func recordingCanceled() {
//        print("-=-=-=-=-=-=--=-=-=-  recordingCanceled -=--=-=-=-=-=-=-=-=-=-=-=-")
        self.timer.invalidate()
        self.videoRecordedSec = 0.0
        btnRecordAni.buttonState = .normal
        self.audioPlayer?.pause()
        self.audioPlayer?.currentTime = .zero
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.recordIconImgView?.transform = .identity
        })
        self.camSettingsView.isHidden = false
        self.galleryIconView.isHidden = false
        self.closeVC.isHidden.toggle()
        self.videoCancelButton.isHidden = true
        self.durationSegment.isHidden = false
        self.videoDoneButton.isHidden = true
        self.progressBar.animateTo(progress: CGFloat(0.0))
    }
    
    func cameraStartFailed() {
        
    }
    
    func cameraStarted() {
//        print("-=-=-=-=-=-=--=-=-=-  cameraStarted -=--=-=-=-=-=-=-=-=-=-=-=-")
    }
    
    func cameraStopped() {
//        print("-=-=-=-=-=-=--=-=-=-  cameraStopped -=--=-=-=-=-=-=-=-=-=-=-=-")
    }
    
    func recordingStarted() {
        btnRecordAni.buttonState = .recording
        audioPlayer?.play()
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.recordIconImgView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        })
        //self.previewDoneBtnsViewOutlet.isHidden = false
        self.camSettingsView.isHidden = true
        self.galleryIconView.isHidden = true
        self.durationSegment.isHidden = true
        self.closeVC.isHidden = true
        self.videoCancelButton.isHidden = false
        self.videoDoneButton.isHidden = true
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { t in
            self.videoRecordedSec += 0.5
            self.progressBar.animateTo(progress: self.videoRecordedSec/self.videoLengthSec)
            if self.videoRecordedSec > self.videoLengthSec {
                self.timer.invalidate()
                self.audioPlayer?.pause()
                self.previewView._captureState = .paused
                self.btnRecordAni.buttonState = .normal
                self.videoDoneButton.isHidden = false
            }
        })
//        print("-=-=-=-=-=-=--=-=-=-  recordingStarted -=--=-=-=-=-=-=-=-=-=-=-=-")
    }
    
    func recordingPaused() {
        self.audioPlayer?.pause()
        self.timer.invalidate()
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.recordIconImgView?.transform = .identity
        })
        btnRecordAni.buttonState = .normal
        self.videoDoneButton.isHidden = false
//        print("-=-=-=-=-=-=--=-=-=-  recordingPaused -=--=-=-=-=-=-=-=-=-=-=-=-")
    }
    
    func recordingResumed() {
//        print("-=-=-=-=-=-=--=-=-=-  recordingResumed -=--=-=-=-=-=-=-=-=-=-=-=-")
    }
    
    func recordingStopped(videoUrl: URL?) {
//        print("-=-=-=-=-=-=--=-=-=-  recordingStopped -=--=-=-=-=-=-=-=-=-=-=-=-")
        self.timer.invalidate()
        self.videoRecordedSec = 0.0
        btnRecordAni.buttonState = .normal
        self.audioPlayer?.currentTime = .zero
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.recordIconImgView?.transform = .identity
        })
        self.camSettingsView.isHidden = false
        self.galleryIconView.isHidden = false
        self.durationSegment.isHidden = false
        self.closeVC.isHidden = false
        self.videoCancelButton.isHidden = true
        self.videoDoneButton.isHidden = true
        self.progressBar.progress = 0.0
        sessionDoneFunc(url: videoUrl)
        
    }
}

extension actionMediaViewController {
// MARK:- ACTION SHEET FOR CROSS BUTTON
    func actionSheetFunc(){
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let startOver: UIAlertAction = UIAlertAction(title: "Start over", style: .default) { action -> Void in
            switch self.btnRecordAni.buttonState {
            case .recording:
                self.btnRecordAni.buttonState = .normal
                
            default:
                break
            }
//            self.endCapture()
            self.progressBar.animateTo(progress: CGFloat(0.0))
            self.loadAudio()
            print("startOver pressed")
        }

        let discard = UIAlertAction(title: "Discard", style: .default) { action -> Void in
            switch self.btnRecordAni.buttonState {
            case .recording:
                self.btnRecordAni.buttonState = .normal
                
            default:
                break
            }
            self.progressBar.animateTo(progress: CGFloat(0.0))
            self.dismiss(animated: true, completion: nil)
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        startOver.setValue(UIColor.red, forKey: "titleTextColor")      // add actions
        actionSheetController.addAction(startOver)
        actionSheetController.addAction(discard)
        actionSheetController.addAction(cancelAction)

        // present an actionSheet...
        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true)
    }
    
    @IBAction func cross(_ sender: Any) {
        if progressBar.progress <= 0.0{
            self.dismiss(animated: true, completion: nil)
        }else{
            actionSheetFunc()
        }
    }
}

//MARK:- CollectionView
extension actionMediaViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.height-20, height: collectionView.frame.height-20)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if filterIndex == indexPath.row{
            return
        }
        self.filterIndex = indexPath.row
        (collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell)?.tickImg.isHidden = false
        self.previewView.toggleFiltering(index: self.filterIndex)
   }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell)?.tickImg.isHidden = true
    }
}

//MARK:- VIDEO PICKER FROM LIBRARY
extension actionMediaViewController:YPImagePickerDelegate{
    private func openPhotosPermissionDialogue(){
        let message = self.photosLisimitedAcces ? "Talent Cash has limit Photos Library access\nTap 'Open Settings' to grant access" : "Talent Cash don't have access to Photos Library\nTap 'Open Settings' to grant access"
        let alert = UIAlertController(title: "Photos permission denied!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default,handler: { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
               UIApplication.shared.open(settingsUrl)
             }
        }))
        present(alert, animated: true)
    }
    func noPhotos() {
        openPhotosPermissionDialogue()
        print("no Photos")
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        print("slec = \(numSelections)")
        return true
    }
    
    @objc func uploadViewAction(sender : UITapGestureRecognizer) {
        if PHPhotoLibrary.authorizationStatus() == .denied {
            self.openPhotosPermissionDialogue()
            return
        }
        if #available(iOS 14, *) {
            self.photosLisimitedAcces = PHPhotoLibrary.authorizationStatus() == .limited
        } else {
            self.photosLisimitedAcces = false
        }
        
        var config = YPImagePickerConfiguration()
        // [Edit configuration here ...]
        // Build a picker with your configuration
        config.video.compression = AVAssetExportPresetMediumQuality
        //config.video.fileType = .mp4
        config.showsVideoTrimmer = true
        config.video.recordingTimeLimit = 500.0
        config.video.libraryTimeLimit = 500.0
        config.video.minimumTimeLimit = 3.0
        config.video.trimmerMaxDuration = 60.0
        config.video.trimmerMinDuration = 3.0
        config.showsPhotoFilters = false
        config.screens = [.library, .video]
        config.library.mediaType = .video
        
        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        picker.didFinishPicking { [unowned picker] items, p0 in
            print("p0 = ",p0," items = ",items.count)
            picker.dismiss(animated: true) {
                let vc =  self.storyboard?.instantiateViewController(withIdentifier: "previewPlayerVC") as! previewPlayerViewController
                guard let vidURL = items.singleVideo?.url else {return}
                vc.url = vidURL
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        present(picker, animated: true) {
            print("completiond")
        }
    }
}

extension actionMediaViewController{
    func mergeVideoWithAudio(videoUrl: URL,audioUrl: URL?,success: @escaping ((URL) -> Void),failure: @escaping ((Error?) -> Void)) {
        let mixComposition: AVMutableComposition = AVMutableComposition()
        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl ?? videoUrl )
        var renderSize = CGSize(width: 480, height: 640)
        let videoInstruction = AVMutableVideoCompositionInstruction()
        if let mutableCompositionVideoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let mutableCompositionAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            renderSize = mutableCompositionVideoTrack.naturalSize
            if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first,
               let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                do {
                    try mutableCompositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
                    let videoDuration = CMTimeMake(value:Int64(Double(aVideoAsset.duration.value)*videoSpeed), timescale:aVideoAsset.duration.timescale)
                    try mutableCompositionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoDuration), of: aAudioAssetTrack, at: CMTime.zero)
                    mutableCompositionVideoTrack.scaleTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAsset.duration), toDuration: videoDuration)
                    if audioUrl == nil{
                        mutableCompositionAudioTrack.scaleTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAsset.duration), toDuration: videoDuration)
                    }
                    mutableCompositionVideoTrack.preferredTransform = aVideoAssetTrack.preferredTransform
                } catch {
                    print("error++++=====>>>>>",error.localizedDescription)
                }
            }
        }
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = renderSize
        mutableVideoComposition.instructions.append(videoInstruction)
        if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\("duetVideo").mp4")
            do {
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    try FileManager.default.removeItem(at: outputURL)
                }
            } catch { }
            
            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                // try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .failed:
                        if let error = exportSession.error {
                            failure(error)
                        }
                        
                    case .cancelled:
                        if let error = exportSession.error {
                            failure(error)
                        }
                        
                    default:
                        print("finished")
                        success(outputURL)
                    }
                })
            } else {
                failure(nil)
            }
        }
    }
}

extension Comparable {

    public func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }

}
