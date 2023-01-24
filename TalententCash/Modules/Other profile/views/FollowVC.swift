//
//  FollowVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 25/10/2022.
//

import UIKit

enum FollowTab {
    case Follower
    case Following
}
class FollowVC:StatusBarController{
    
    @IBOutlet weak var followerIndicator: UIView!
    @IBOutlet weak var followingIndicator: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabelFollower: UILabel!
    @IBOutlet weak var emptyLabelFollowing: UILabel!
    private var followerList:[FollowUser] = []
    private var followingList:[FollowUser] = []
    private var isLoadingFollowers = false
    private var isLoadingFollowing = false
    private var page = 0
    var user:User!
    var selectedtTab:FollowTab = .Follower
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        self.nameLabel.text = user.name
        updateUI()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if followerList.isEmpty{
            fetchFollowers()
        }
        if followingList.isEmpty{
            fetchFollowings()
        }
//        self.updateUI()
    }
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func followerTap(_ sender: Any) {
        selectedtTab = .Follower
        self.updateUI()
        tableView.reloadData()
        emptyLabelFollowing.isHidden = true
        if followerList.isEmpty{
            self.fetchFollowers()
        }
    }
    @IBAction func followingTap(_ sender: Any){
        selectedtTab = .Following
        tableView.reloadData()
        self.updateUI()
        emptyLabelFollower.isHidden = true
        if followingList.isEmpty{
            self.fetchFollowings()
        }
    }
    private func updateUI(){
        print(selectedtTab)
        followingIndicator.backgroundColor = selectedtTab == .Following ? UIColor(named: "primary")! : .clear
        followerIndicator.backgroundColor = selectedtTab == .Follower ? UIColor(named: "primary")! : .clear
    }
    private func fetchFollowings(searchText:String = ""){
        if isLoadingFollowing{
            return
        }
        self.emptyLabelFollowing.isHidden = true
        self.isLoadingFollowing = true
        self.startPulseAnimation()
        NetworkUtil.request(dataType: FollowUsersResponse.self, apiMethod: Constants.URL.following+"?userId=\(user._id )&start=0&limit=100&search=\(searchText)") { data in
            self.isLoadingFollowing = false
            self.stopPulseAnimation()
            if data.status{
                self.followingList = data.user
                self.tableView.reloadData()
            }else{
                self.showToast(message: data.message)
            }
            self.emptyLabelFollowing.isHidden = !self.followingList.isEmpty || self.selectedtTab == .Follower
        } onFailure: { m, msg in
            self.emptyLabelFollowing.isHidden = !self.followingList.isEmpty || self.selectedtTab == .Follower
            self.isLoadingFollowing = false
            self.stopPulseAnimation()
        }
    }
    private func fetchFollowers(searchText:String = ""){
        if isLoadingFollowers{
            return
        }
        self.emptyLabelFollower.isHidden = true
        self.isLoadingFollowers = true
        self.startPulseAnimation()
        NetworkUtil.request(dataType: FollowUsersResponse.self, apiMethod: Constants.URL.follower+"?userId=\(user._id)&start=0&limit=100&search=\(searchText)") { data in
            self.isLoadingFollowers = false
            self.stopPulseAnimation()
            if data.status{
                self.followerList = data.user
                self.tableView.reloadData()
            }else{
                self.showToast(message: data.message)
            }
            self.emptyLabelFollower.isHidden = !self.followerList.isEmpty || self.selectedtTab == .Following
        } onFailure: { m, msg in
            self.emptyLabelFollower.isHidden = !self.followerList.isEmpty || self.selectedtTab == .Following
            self.isLoadingFollowers = false
            self.stopPulseAnimation()
//            self.showToast(message: msg)
        }
    }
}

//MARK: SearchBar Delegate Mehods
extension FollowVC:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
       
        if let t = searchBar.text,!t.isEmpty{
            self.page = 0
            if selectedtTab == .Follower{
                fetchFollowers(searchText: t)
            }else{
                fetchFollowings(searchText: t)
            }
            searchBar.text = ""
        }
    }
}

//MARK: UICollectionView Delegate Mehods
extension FollowVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.selectedtTab == .Follower ? self.followerList.count : self.followingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! followTableViewCell
//        cell.followButton.addTarget(self, action: #selector(self.followButtonTap), for: .touchUpInside)
//        cell.followButton.tag = indexPath.row
        cell.item = self.selectedtTab == .Follower ? self.followerList[indexPath.row] : self.followingList[indexPath.row]
        return cell
    }
    
//    @objc private func followButtonTap(sender:UIButton){
//        if isLoading{
//            return
//        }
//        UIViewController.displaySpinner(onView: view)
//        isLoading = true
//        NetworkUtil.request(apiMethod: Constants.URL.follow, parameters: ["to":self.selectedtTab == .Follower ? self.followerList[sender.tag] : self.followingList[sender.tag],"from":loggedUserId]) { data in
//            self.stopPulseAnimation()
//            self.isLoading = false
//            guard let data = data as? Data else {
//                return
//            }
//            do{
//                let jo = try JSONSerialization.jsonObject(with: data,options: .mutableContainers)
//                if let json = jo as? [String:Any],let status = json["status"] as? Bool, let m = json["message"] as? String,let follow = json["isFollow"] as? Bool {
//                    if status{
//                        if self.selectedtTab == .Follower{
//                            self.followerList[sender.tag].isFollow = follow
//                        }else{
//                            self.followingList[sender.tag].isFollow = follow
//                        }
//                        self.tableView.reloadData()
//                    }else{
//                        self.showToast(message: m, font: .systemFont(ofSize: 18))
//                    }
//                }else{
//                    self.showToast(message: NetworkError.serverError.rawValue, font: .systemFont(ofSize: 18))
//                }
//            }catch{
//                self.showToast(message: NetworkError.serverError.rawValue, font: .systemFont(ofSize: 18))
//            }
//        } onFailure: { t, m in
//            self.isLoading = false
//            self.stopPulseAnimation()
//            self.showToast(message: m, font: .systemFont(ofSize: 18))
//        }
//    }
}
