//
//  ProfileVideoCell.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 14/09/2022.
//

import UIKit
import Reusable
import MarqueeLabel
import SDWebImage
import NVActivityIndicatorView

class ProfileCollectionViewHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var bioInfo: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
//    @IBOutlet weak var lblGifts: UILabel!
    
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var followersStack: UIStackView!
    @IBOutlet weak var bookingButton: ButtonGradientBackground!
    var editProfileClick:()->Void = { }
    var bookingButtonClick:()->Void = { }
    var user : User! {
        didSet{
            setupUI()
        }
    }
    
    func setupUI() {    
        bookingButton.setTitle(UserDefaultManager.instance.userType == .talent ? "Booking" : "Talent Booking", for: .normal)
        self.userName.text = self.user.name
        UserDefaults.standard.set(self.user.name, forKey: "user_name")
        UserDefaults.standard.set(self.user.username, forKey: "user_username")
        UserDefaults.standard.set(self.user.coin, forKey: "user_coins")
        self.bioInfo.text = self.user.bio
        self.lblFollowers.text = "\(self.user.followers )"
        self.lblFollowing.text = "\(self.user.following )"
       // self.lblGifts.text = "\(self.user.coin ?? 0)"
        followersStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openFollowersList)))
        followingStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openFollowingsList(_:))))
        
        let lv = NVActivityIndicatorView(frame: .zero)
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.type = .circleStrokeSpin
        lv.color = UIColor.init(named: "primary") ?? UIColor.systemPink
        self.profileImageView.addSubview(lv)
        NSLayoutConstraint.activate([
            lv.centerXAnchor.constraint(equalTo: self.profileImageView.centerXAnchor),
            lv.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor),
            lv.widthAnchor.constraint(equalTo: self.profileImageView.widthAnchor, multiplier: 0.5),
            lv.heightAnchor.constraint(equalTo: self.profileImageView.widthAnchor, multiplier: 0.5),
        ])
        lv.startAnimating()
        self.profileImageView.sd_setImage(with: .init(string: self.user.profileImage)){_,_,_,_ in
            lv.stopAnimating()
            lv.removeFromSuperview()
        }
    }
    @objc private func openFollowersList(_ sender:Any){
        let vc = UIStoryboard(name: "otherProfile", bundle: nil).instantiateViewController(withIdentifier: "FollowVC") as! FollowVC
        vc.user = user
        vc.selectedtTab = .Follower
        UIApplication.topViewController()?.present(vc, animated: true)
    }
    @objc private func openFollowingsList(_ sender:Any){
        let vc = UIStoryboard(name: "otherProfile", bundle: nil).instantiateViewController(withIdentifier: "FollowVC") as! FollowVC
        vc.user = user
        vc.selectedtTab = .Following
        UIApplication.topViewController()?.present(vc, animated: true)
    }
    @IBAction func bookingOpen(_ sender: Any) {
        bookingButtonClick()
    }
    @IBAction func editProfileBtn(_ sender: Any) {
        editProfileClick()
    }
}


