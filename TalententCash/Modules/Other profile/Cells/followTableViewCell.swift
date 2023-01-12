//
//  followTableViewCell.swift
//  Talent Cash
//
//  Created by MacBook Pro on 25/10/2022.
//

import UIKit

class followTableViewCell:UITableViewCell{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var item:FollowUser! {
        didSet{
            setData()
        }
    }
    private func setData(){
        self.profileImageView.sd_setImage(with: URL(string: item.image), placeholderImage: UIImage(named: "placeholder.user"))
        self.nameLabel.text = item.name
        self.usernameLabel.text = item.username
//        self.followButton.backgroundColor = item.isFollow ? .lightText : .clear
//        self.followButton.setTitle(item.isFollow ? "Following" : "Follow", for: .normal)
    }
}
