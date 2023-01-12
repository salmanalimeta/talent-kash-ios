//
//  DiscoverySearchController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 21/09/2022.
//

import UIKit
import Alamofire
enum DiscoverySearchKind :Int{
    case People = 0
    case HashTag = 1
}

class DiscoverySearchController:StatusBarController{
    private var searchkind = DiscoverySearchKind.People
    @IBOutlet weak  var selectedSearchButton:UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //    private var searchedList:[String] = []
    @IBOutlet weak var emptyLabel: UILabel!
    //    private var dataList:[String] = ["new user","old user","happy user","angry user","wanted user"]
    private var hashTagList:[Hashtag] = []
    private var userList:[User] = []
    private let limit = "20"
    private var page:Int=0
    private var isDataLoading = false
    private var didEndReached = false
    private var searchText = ""
    private lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        return refreshControl
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.refreshControl = refresher
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.loadUserData()
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "search here", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "separator") ?? .systemGray])
        }
    }
    @objc func refreshData(_ sender:Any){
        searchText = ""
        if searchkind == .HashTag{
            self.loadUserData()
        }else{
            self.loadUserData()
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+1, execute: {
            self.refresher.endRefreshing()
        })
    }
    
    @IBAction func backClick(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func searchHashTagClick(_ sender: UIButton) {
        updateSearchKindUI(button: sender)
        if hashTagList.isEmpty || !self.searchText.isEmpty{
            self.searchText = ""
            self.loadhashTags()
        }
    }
    @IBAction func searchPeopleClick(_ sender: UIButton) {
        updateSearchKindUI(button: sender)
        if userList.isEmpty || !self.searchText.isEmpty{
            self.searchText = ""
            self.loadUserData()
        }
    }
    private func updateSearchKindUI(button:UIButton){
        if self.isDataLoading{
            return
        }
        selectedSearchButton.backgroundColor = .clear
        searchkind = .init(rawValue: button.tag) ?? .People
        button.backgroundColor = UIColor(named: "primaryColor") ?? UIColor.systemPink
        selectedSearchButton = button
        tableView.reloadData()
        
        if userList.isEmpty || !self.searchText.isEmpty{
            self.searchText = ""
            self.loadUserData()
        }
        if hashTagList.isEmpty{
            self.loadhashTags()
        }
    }
    private func loadhashTags(){
        if self.isDataLoading{
            return
        }
        self.isDataLoading = true
        emptyLabel.isHidden = true
        self.startPulseAnimation()
        let escapedString = Constants.URL.hashTags(type: searchText,start: page,limit: limit,userId: UserDefaultManager.instance.userID).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        NetworkUtil.request(dataType:HashTagResponse.self,apiMethod:escapedString , onSuccess: {response in
            self.isDataLoading = false
            self.stopPulseAnimation()
            if response.status {
                if response.hashtag.isEmpty{
                    print("data len 0")
                    self.didEndReached = true
                }else{
                    self.hashTagList  = response.hashtag.filter({$0.reel.count > 0 && !($0.hashtag.isEmpty)})
                    self.tableView.reloadData()
                    print("data len -", self.hashTagList.count)
                }
            }else{
                self.showToast(message: response.message)
            }
            if self.hashTagList.isEmpty{
                self.emptyLabel.isHidden = false
            }
        }, onFailure: {_,error in
            if self.hashTagList.isEmpty{
                self.emptyLabel.isHidden = false
            }
            self.isDataLoading = false
            self.stopPulseAnimation()
            print(error)
        })
    }
    private func loadUserData(){
        if self.isDataLoading{
            return
        }
        emptyLabel.isHidden = true
        self.isDataLoading = true
        self.startPulseAnimation()
        NetworkUtil.request(dataType: UserSearchResponse.self, apiMethod: Constants.URL.userSearch,parameters: ["userId":UserDefaultManager.instance.userID,"search":searchText],requestType: .post, onSuccess: { response in
            self.isDataLoading = false
            self.stopPulseAnimation()
            print(response.message)
            if response.status {
                if response.search.isEmpty{
                    print("data len 0")
                    self.didEndReached = true
                }else{
                    self.userList  = response.search
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }else{
                self.showToast(message: response.message)
            }
            if self.userList.isEmpty{
                self.emptyLabel.isHidden = false
            }
        }, onFailure: {_,error in
            if self.userList.isEmpty{
                self.emptyLabel.isHidden = false
            }
            self.isDataLoading = false
            self.stopPulseAnimation()
            print(error)
        })
    }
}
// MARK: UISearchBar delegate
extension DiscoverySearchController:UISearchBarDelegate{
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
            searchText = t
            if searchkind == .People{
                loadUserData()
            }else{
                self.page = 0
                loadhashTags()
            }
            searchBar.text = ""
        }
    }
}
//MARK: UITable view Delegate
extension DiscoverySearchController :UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchkind == .People ? userList.count : hashTagList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DiscoverySearchTableViewCell
        if searchkind == .People{
            cell.user = userList[indexPath.row]
        }else{
            cell.hashTags = hashTagList[indexPath.row]
        }
        return cell
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
        {
            if !isDataLoading && !didEndReached && searchkind == .HashTag{
                self.page += 1
                loadhashTags()
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchkind == .HashTag{
            let vc = UIStoryboard(name: "Discovery", bundle: nil).instantiateViewController(withIdentifier: "DiscoveryTagController") as! DiscoveryTagController
            vc.tag = self.hashTagList[indexPath.row]
            UIApplication.topViewController()?.present(vc, animated: true)
        }else{
            let loggedUserId = UserDefaultManager.instance.userID
            if self.userList[indexPath.row]._id != loggedUserId{
                let vc = UIStoryboard(name: "otherProfile", bundle: nil).instantiateViewController(withIdentifier: "OthersProfileController") as! OthersProfileController
                vc.user = self.userList[indexPath.row]
                UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
            }
        }
    }
}
