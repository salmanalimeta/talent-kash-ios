//
//  EditingViewController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 19/01/2023.
//

import UIKit
import PryntTrimmerView
import AVKit


class EditingViewController: StatusBarController {

    @IBOutlet weak var playerView: UIView!
   
    var player: AVPlayer?
    var currentAsset: AVAsset!
    var videoStartTime:Double = 0.0
    var videoEndTime:Double = 0.0
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    @IBOutlet weak var trimmerView: TrimmerView!
    var url:URL?
    var SpeedValue:Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.darkGray
        if url != nil{
            DispatchQueue.main.async {
                self.currentAsset = AVAsset(url: self.url!)
                self.loadAsset(self.currentAsset)
                
            }
            
        }
    }
    @IBAction func Done(_ sender: Any) {
        
    //  let outputUrl = self.cropVideo(sourceURL:self.url!, startTime: self.videoStartTime, endTime: self.videoEndTime)
        self.startPulseAnimation()
        self.player?.pause()
        self.cropVideo(sourceURL:self.url!, startTime: self.videoStartTime, endTime: self.videoEndTime, completion: { (outputUrl) -> Void in
            DispatchQueue.main.async {
                self.stopPulseAnimation()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postViewController
                vc.videoUrl = outputUrl
                vc.SpeedValue = self.SpeedValue
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            
        })
 
    
       
    }
    

    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil){
    
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")

        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")
        }catch let error {
            print(error)
        }

        //Remove existing file
        try? fileManager.removeItem(at: outputURL)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return}
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))

        exportSession.timeRange = timeRange
        
        exportSession.exportAsynchronously {
            
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
           
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
               
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
              
            default: break
            }
        }
      
    }
    
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
      let playerItem = AVPlayerItem(asset: asset)
      player = AVPlayer(playerItem: playerItem)
      
      NotificationCenter.default.addObserver(self, selector: #selector(EditingViewController.itemDidFinishPlaying(_:)),
                                             name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
      
      let layer: AVPlayerLayer = AVPlayerLayer(player: player)
      layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
      layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
      playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
      playerView.layer.addSublayer(layer)
        guard let player = player else { return }
        player.play()
        startPlaybackTimeChecker()
        
//
//
//        if !player.isPlaying {
//          player.play()
//          startPlaybackTimeChecker()
//        } else {
//          player.pause()
//
//          stopPlaybackTimeChecker()
//        }
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
      if let startTime = trimmerView.startTime {
        player?.seek(to: startTime)
        
      }
    }
    
    func startPlaybackTimeChecker() {
      
      stopPlaybackTimeChecker()
      playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                      selector:
        #selector(EditingViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
      
      playbackTimeCheckerTimer?.invalidate()
      playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
      
      guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
        return
      }
      
      let playBackTime = player.currentTime()
      trimmerView.seek(to: playBackTime)
      
      if playBackTime >= endTime {
          player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        trimmerView.seek(to: startTime)
      }
    }
    
    //MARK:- Actions
   
 
    
   func loadAsset(_ asset: AVAsset) {
      
      trimmerView.asset = asset
      trimmerView.delegate = self
      addVideoPlayer(with: asset, playerView: playerView)
    }
    
  }

  extension EditingViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
      player?.play()
      startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
      stopPlaybackTimeChecker()
      player?.pause()
      player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
      let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        self.videoStartTime = trimmerView.startTime?.seconds ?? 0
        self.videoEndTime = trimmerView.endTime?.seconds ?? 0
        //playerView.pla
      print(duration)
    }
  }

  extension AVPlayer {
    
    var isPlaying: Bool {
      return self.rate != 0 && self.error == nil
    }
  }
