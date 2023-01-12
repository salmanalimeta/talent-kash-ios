//
//  OthersProfileCollectionViewHeaderCell.swift
//  Talent Cash
//
//  Created by Aamir on 14/10/2022.
//

import UIKit
import NVActivityIndicatorView

class OthersProfileCollectionViewHeaderCell:UICollectionReusableView{

//    @IBOutlet weak var diamondCounter: UILabel!
    @IBOutlet weak var followingCounter: UILabel!
    @IBOutlet weak var followerCounter: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var user:User!{
        didSet{
            setData()
        }
    }
    private func setData(){
        followButton.setTitle(user.isBlock ? "UNBLOCK" : user.isFollow ?  "FOLLOWING" : "FOLLOW" , for:  .normal)
        followButton.setImage(user.isBlock ? nil : user.isFollow ?  nil : UIImage(named: "person.follow"), for:  .normal)
        followButton.backgroundColor = UIColor(named: user.isFollow ? "unfollowButton" : "followButton")!
        chatButton.isHidden = user.isBlock
        blockButton.isHidden = user.isBlock
        
//        self.profileImage.sd_setImage(with: URL(string: user.profileImage ?? "" ), placeholderImage: UIImage(named: "placeholder.user"))
        self.nameLabel.text = user.name
        self.followerCounter.text = "\(user.followers)"
        self.followingCounter.text = "\(user.following )"
//        self.diamondCounter.text = "\(user.coin ?? 0)"
        self.userBio.text = user.bio
        
        let lv = NVActivityIndicatorView(frame: .zero)
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.type = .circleStrokeSpin
        lv.color = UIColor.init(named: "primary") ?? UIColor.systemPink
        self.profileImage.addSubview(lv)
        NSLayoutConstraint.activate([
            lv.centerXAnchor.constraint(equalTo: self.profileImage.centerXAnchor),
            lv.centerYAnchor.constraint(equalTo: self.profileImage.centerYAnchor),
            lv.widthAnchor.constraint(equalTo: self.profileImage.widthAnchor, multiplier: 0.5),
            lv.heightAnchor.constraint(equalTo: self.profileImage.widthAnchor, multiplier: 0.5),
        ])
        lv.startAnimating()
        self.profileImage.sd_setImage(with: .init(string: self.user.profileImage )){_,_,_,_ in
            lv.stopAnimating()
            lv.removeFromSuperview()
        }
    }
}
