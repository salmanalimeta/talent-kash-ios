//
//  NotificationsViewController.swift
//  Fresh Box
//
//  Created by Zohaib Baig on 08/06/2022.
//

import UIKit
import Foundation
import Alamofire
import AVFAudio
import SwiftUI
import NVActivityIndicatorView
import AVFoundation

class GetSongsViewController: StatusBarController {

    var window: UIWindow?
    
    @IBOutlet weak var getSongsCollectionView: UITableView!
    //@IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var Songlabel: UILabel!
    
    @IBOutlet weak var songDur: UILabel!
    
    @IBOutlet weak var SEARCHBORDER: UIView!
    
    @IBOutlet weak var progressbar: UISlider!
    
    var updater : CADisplayLink! = nil
    
    var isSearch : Bool = false
    var filteredTableData:[SongModel] = []
    var fileDownloadedLink:URL?
    var songName:String?
    var selectedIndex : [Int:Int]?
    
    @IBOutlet weak var btnPlay: UIButton!
    
//    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    //@IBOutlet weak var bottomView: UIView!
    //@IBOutlet weak var noDataFound: UIView!
    //@IBOutlet weak var play_btn_ref: UIButton!
    //@IBOutlet weak var progressView: UIProgressView!
    //@IBOutlet weak var timeLabel: UILabel!
   // @IBOutlet weak var audioView: UIView!
   
    var audioPlayer : AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var voiceRecordingOn: Int = 0
    var fileName = "audio_file.m4a"
    var timer: Timer?
    var totalDuration: String?
    var offset:Int = 0
    var isLoadingList: Bool = false
    var loadMore: Bool = true
    
    @IBOutlet weak var txtSearch: UITextField!
    var getSongsDataSource: [SongModel] = []
//
    var songDataSource : GetSongModel = GetSongModel(status: false, message: "", song: []) {
        didSet {
            getSongsDataSource = songDataSource.song
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressbar.isUserInteractionEnabled = false
        getSongsCollectionView.delegate = self
        getSongsCollectionView.dataSource = self
        //configureSearchBar()
        selectedIndex = [Int:Int]()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getSongsList()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.audioPlayer = nil
    }

    
//    func configureSearchBar() {
//        searchBar.showsCancelButton = false
//        searchBar.delegate = self
//
//    }
    
    @IBAction func playTab(_ sender: Any) {
        
        if btnPlay.image(for: .normal) == UIImage(named: "ic_play_icon"){
            
            self.btnPlay.setImage(UIImage(named: "pause-button"), for: .normal)
            
            if self.audioPlayer != nil{
                self.audioPlayer.play()
                
            }
            
        }else{
            if self.audioPlayer != nil{
                self.audioPlayer.pause()
                
            }
            
            self.btnPlay.setImage(UIImage(named: "ic_play_icon"), for: .normal)
            
        }
        
    }
    
//
//    func searchQuery(searchText: String?) {
//        guard let searchText = searchText, searchText != "" else {
//            getSongsDataSource = songDataSource
//            return
//        }
//    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.playerView.alpha = 0
        if self.audioPlayer != nil{
            audioPlayer.stop()
            updater.invalidate()
        }
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        
        self.playerView.alpha = 0
        if self.audioPlayer != nil{
            audioPlayer.stop()
            updater.invalidate()
        }
  
        UserDefaults.standard.set(self.fileDownloadedLink, forKey: "songURL")
        UserDefaults.standard.set(self.songName, forKey: "songName")
        self.dismiss(animated: true)
        
        
    }
    
    @IBAction func FinalFone(_ sender: Any) {
        self.playerView.alpha = 0
        if self.audioPlayer != nil{
            audioPlayer.stop()
            updater.invalidate()
        }
        UserDefaults.standard.set(self.fileDownloadedLink, forKey: "songURL")
        UserDefaults.standard.set(self.songName, forKey: "songName")
        self.dismiss(animated: true, completion: nil)
    }
    
     
    func getSongsList() {
        self.startPulseAnimation()
        NetworkUtil.request(apiMethod: Constants.baseUrl+"song", parameters: nil, requestType: .get, showProgress: false, encoding: JSONEncoding.default, view: nil, onSuccess: {data in
            self.stopPulseAnimation()
                    guard let data = data as? Data else {
                        print("cast error")
                        return
                    }
        //            print(String(data: data, encoding: .utf8) ?? "")
                    do{
                        self.songDataSource = try JSONDecoder().decode(GetSongModel.self, from:  data)
                        self.getSongsCollectionView.reloadData()
                        if self.getSongsDataSource.count > 0{
                            for i in 0..<self.getSongsDataSource.count {
                                let obj = self.getSongsDataSource[i]
                                //let audioUrl1 = myURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                
                                //let replaced = obj.song.replacingOccurrences(of: "\\", with: "/")
                                
                               // let audioUrl1 = replaced.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                
                                if let audioUrl = URL(string: obj.song ) {
                                    
                                    
                                    print(audioUrl)
                                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                    
                                    // lets create your destination file url
                                    let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                                    print(destinationUrl)
                                    
                                    // to check if it exists before downloading it
                                    if FileManager.default.fileExists(atPath: destinationUrl.path) {
                                        
                                        
                                    }else {
                                        
                                        // you can use NSURLSession.sharedSession to download the data asynchronously
                                        URLSession.shared.downloadTask(with: audioUrl) { [self] location, response, error in
                                            guard let location = location, error == nil else { return }
                                            do {
                                                // after downloading your file you need to move it to your destination url
                                                try FileManager.default.moveItem(at: location, to: destinationUrl)
                                                print("File moved to documents folder")
                                                
                                            } catch {
                                                print(error)
                                            }
                                        }.resume()
                                    }
                                }
                                
                            }
                        }
                        
                    } catch {
                        print("error: ", error)
                    }
                    
                }) { _,error in
                    self.stopPulseAnimation()
                    print("error--",error)
                }

    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = (scrollView.contentOffset.y + scrollView.frame.size.height)
        if ((scrollViewHeight > scrollView.contentSize.height ) && !isLoadingList && loadMore) {
            isLoadingList = true
            offset += 1
            getSongsList()
        }
    }
    
    @IBAction func dismissPlayerView(_ sender: Any) {
//        self.bottomView.isHidden = !self.bottomView.isHidden
//
////        bottomViewHeight.constant = (bottomViewHeight.constant == 180) ? 0 : 180
//        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut) {
//            self.view.layoutIfNeeded()
//        }

    }

    
//    @IBAction func playSongAction(_ sender: Any) {
//        playAct()
//    }
//        bottomViewHeight.constant = (bottomViewHeight.constant == 180) ? 0 : 180
//        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut) {
//            self.view.layoutIfNeeded()
//        }

//    func playAct() {
//        play_btn_ref.isSelected = !(play_btn_ref.isSelected)
//        if play_btn_ref.isSelected {
//            play_btn_ref.setImage(UIImage.init(named: "pauseIcon"), for: .normal)
//            audioPlayer?.play()
//
//            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
//                guard let self = self else { return }
////                print("Time \(self.stringFromTimeInterval(interval: self.audioPlayer!.currentTime))")
//                self.trackAudio(time: self.stringFromTimeInterval(interval: self.audioPlayer!.currentTime))
//            })
//
//        } else {
//            play_btn_ref.setImage(UIImage.init(named: "PlayButton"), for: .normal)
//            audioPlayer?.pause()
//            timer?.invalidate()
//        }
//    }
    
//    func trackAudio(time: String) {
//        guard let item = audioPlayer else {return}
//        let timePercentage = (item.currentTime / item.duration)
////        print("progress \((item.currentTime / item.duration))")
//        progressView.progress = Float(timePercentage)
//        timeLabel.text = time
//    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = (interval % 60)
        let minutes = (interval / 60) % 60
//        let hours = (interval / 3600)
//        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func backViewController(_ sender: Any) {
        self.playerView.alpha = 0
        audioPlayer?.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func trackAudio() {
        if self.audioPlayer != nil{
            let normalizedTime = Float(audioPlayer.currentTime / audioPlayer.duration)
            progressbar.value = normalizedTime
            print("time = ",audioPlayer.currentTime)
           // self.songDur.text = "\(normalizedTime)"
            self.songDur.text = self.stringFromTimeInterval(interval: audioPlayer.currentTime)
        }
        
     }
//
//    @IBAction func textFieldChanges(_ textField: UITextField) {
//
//        if textField.text?.count == 0 {
//                        isSearch = false
//                        self.getSongsCollectionView.reloadData()
//                    } else {
//
//
//                    }
//    }

    func getSearchArrayContains(_ text : String) {

        filteredTableData = self.getSongsDataSource.filter({$0.title.lowercased().contains(text)})
        isSearch = true
        getSongsCollectionView.reloadData()
    }
    
}


extension GetSongsViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        var searchText  = textField.text! + string
        
        if searchText  == nil {
            searchText = (searchText as String).substring(to: searchText.index(before: searchText.endIndex))
        }
        if string  == "" {
            isSearch = false
            self.getSongsCollectionView.reloadData()
        }
        else{
            if searchText.count > 2 {
                print(searchText)
                self.getSearchArrayContains(searchText)
                
                
            }
            
        }
        
        return true
    }

}


extension GetSongsViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearch == true) {
            return filteredTableData.count
        }else{
            return getSongsDataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : GetSongsCell = tableView.dequeueReusableCell(withIdentifier: "GetSongsCell", for: indexPath) as! GetSongsCell
        if (isSearch == true) {
            //cell.setupData(model: )
            let model = filteredTableData[indexPath.row]
            cell.userImg.sd_setImage(with: URL(string:model.image), placeholderImage: UIImage(named: "placeholder.user"))
            cell.title.text = model.title
            cell.subtitle.text = model.singer
            cell.contentView.backgroundColor = model.selectedSong ? UIColor(named: "primary")!.withAlphaComponent(0.35) : .clear
        }else{
            //cell.setupData(model: getSongsDataSource[indexPath.row])
            
            let model = getSongsDataSource[indexPath.row]
            cell.userImg.sd_setImage(with: URL(string: model.image), placeholderImage: UIImage(named: "placeholder.user"))
            cell.title.text = model.title
            cell.subtitle.text = model.singer
            cell.contentView.backgroundColor = model.selectedSong ? UIColor(named: "primary")!.withAlphaComponent(0.35) : .clear
        }
       
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor(named: "primary")!.withAlphaComponent(0.35)
        var obj = getSongsDataSource[indexPath.row]
        getSongsDataSource[indexPath.row].selectedSong = true
        self.view.endEditing(true)
        if (isSearch == true) {
            obj = filteredTableData[indexPath.row]
//            tableView.reloadData()
            self.btnPlay.setImage(UIImage(named: "pause-button"), for: .normal)
            self.playerView.alpha = 1
            selectedIndex?.removeAll()
            selectedIndex?.updateValue(indexPath.row, forKey: indexPath.section)
        }else{
            obj = getSongsDataSource[indexPath.row]
//            tableView.reloadData()
            self.btnPlay.setImage(UIImage(named: "pause-button"), for: .normal)
            self.playerView.alpha = 1
            selectedIndex?.removeAll()
            selectedIndex?.updateValue(indexPath.row, forKey: indexPath.section)
        }
        self.Songlabel.text  = obj.title
        if self.audioPlayer != nil{
            progressbar.value = 0.0
            self.songDur.text = "00:00"
            audioPlayer.stop()
            updater.invalidate()
        }
        UserDefaults.standard.set(obj.id, forKey: "song_id")
        if let audioUrl = URL(string: obj.song ) {
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                print(destinationUrl)
                // to check if it exists before downloading it
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                        self.fileDownloadedLink = destinationUrl
                        self.songName = obj.title
                        UserDefaults.standard.set(obj.id, forKey: "song_id")
                        NotificationCenter.default.post(name: Notification.Name("songAdded"), object:nil, userInfo: ["song_id":obj.id])
                        guard let player = audioPlayer else { return }
                        
                        updater = CADisplayLink(target: self, selector: #selector(self.trackAudio))
                        updater.preferredFramesPerSecond = 1
                        updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
                      
                        self.progressbar.minimumValue = 0
                        self.progressbar.maximumValue = 1
                        player.prepareToPlay()
                        player.volume = 1.0
                        player.play()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }else {
                    // you can use NSURLSession.sharedSession to download the data asynchronously
                    URLSession.shared.downloadTask(with: audioUrl) { [self] location, response, error in
                        guard let location = location, error == nil else { return }
                        do {
                            // after downloading your file you need to move it to your destination url
                            try FileManager.default.moveItem(at: location, to: destinationUrl)
                            print("File moved to documents folder")
                            DispatchQueue.main.async {
                                self.playerView.alpha = 1
                            }
                            self.stopPulseAnimation()
                            do {
                                self.audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                                self.fileDownloadedLink = destinationUrl
                                self.songName = obj.title
                                UserDefaults.standard.set(obj.id, forKey: "song_id")
                                NotificationCenter.default.post(name: Notification.Name("songAdded"), object:nil, userInfo: ["song_id":obj.id])
                                guard let player = self.audioPlayer else { return }
                                updater = CADisplayLink(target: self, selector: #selector(self.trackAudio))
                                updater.preferredFramesPerSecond = 1
                                updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
                                self.progressbar.minimumValue = 0
                                self.progressbar.maximumValue = 1
                                
                                player.prepareToPlay()
                                player.volume = 1.0
                                player.play()
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        } catch {
                            print(error)
                        }
                    }.resume()
                }
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = .clear
        getSongsDataSource[indexPath.row].selectedSong = false
    }
}
