//
//  DiscoveryController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 15/09/2022.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class DiscoveryController: StatusBarController {
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private var isDataLoading = false
    private let limit = "20"
    private var page:Int=0 
    private var didEndReached = false
    private var hashTagList:[Hashtag] = []
    private var selectedTag:Hashtag!
    @IBOutlet weak var progressIndicator:NVActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        //AppUtility?.startLoader(view: view)
        //        progressIndicator.startAnimating()
        //        progressIndicator.type = .circleStrokeSpin
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
        isDataLoading = true
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let tag = sender as! Hashtag
//        if segue.identifier == "DiscoveryTagController" {
//            (segue.destination as! DiscoveryTagController).tag = tag
//        }
//    }
    
    
    private func loadData(){
        if hashTagList.isEmpty{
            self.startPulseAnimation()
        }
        let escapedString = Constants.URL.hashTags(start: page,limit: limit,userId: UserDefaultManager.instance.userID).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        NetworkUtil.request(dataType:HashTagResponse.self,apiMethod:escapedString, onSuccess: {response in
            self.isDataLoading = false
            if self.hashTagList.isEmpty{
                self.stopPulseAnimation()
            }
            print(response.message)
            if response.status {
                if response.hashtag.isEmpty{
                    print("data len 0")
                    self.didEndReached = true
                }else{
                    if self.hashTagList.isEmpty{
                        self.hashTagList.append(Hashtag())
                    }
                    self.page += 1
                    self.hashTagList  += response.hashtag.filter({$0.reel.count > 0 && !($0.hashtag.isEmpty)})
                    self.tableView.reloadData()
                    print("data len -",response.hashtag.count)
                }
            }
            self.emptyLabel.isHidden = !self.hashTagList.isEmpty
        }, onFailure: {_,error in
            self.isDataLoading = false
            self.stopPulseAnimation()
            print(error)
            self.emptyLabel.isHidden = !self.hashTagList.isEmpty
            self.showToast(message: error)
        })
    }
}

extension DiscoveryController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ?  tableView.frame.width*0.65 :  tableView.frame.width*0.65
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.hashTagList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier:"sliderCell", for: indexPath) as! DiscoveryCarouselCell
            cell.setData()
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier:"collectionCell", for: indexPath) as! DiscoveryTableViewCell
            cell.item = self.hashTagList[indexPath.row]
            cell.hashtagImage.image = .init(named: indexPath.row%2 == 0 ? "hash1" : "hash")!
            cell.videoLikeHandle = {reel in
                if let k = self.hashTagList.firstIndex(where: {$0.hashtag == self.hashTagList[indexPath.row].hashtag}) , let i = self.hashTagList[k].reel.firstIndex(where: {$0._id == reel._id}){
                    self.hashTagList[k].reel.remove(at: i)
                    self.hashTagList[k].reel.insert(reel, at: i)
                    cell.collectionView.reloadItems(at: [.init(row: i, section: 0)])
                }
            }
            cell.onViewAllClick = {item in
//                self.performSegue(withIdentifier: "DiscoveryTagController", sender: item)
                let vc = UIStoryboard(name: "Discovery", bundle: nil).instantiateViewController(withIdentifier: "DiscoveryTagController") as! DiscoveryTagController
                vc.tag = item
                vc.videoLikeHandle = {reel in
                    if let k = self.hashTagList.firstIndex(where: {$0.hashtag == item.hashtag}) , let i = self.hashTagList[k].reel.firstIndex(where: {$0._id == reel._id}){
                        self.hashTagList[k].reel.remove(at: i)
                        self.hashTagList[k].reel.insert(reel, at: i)
                        cell.collectionView.reloadItems(at: [.init(row: i, section: 0)])
                    }
                }
                self.present(vc, animated: true)
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.self.hashTagList.count-6 && !self.isDataLoading && !self.didEndReached{
            self.loadData()
        }
    }
}
