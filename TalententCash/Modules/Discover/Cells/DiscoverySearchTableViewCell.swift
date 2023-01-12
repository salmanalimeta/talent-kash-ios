//
//  DiscoverySearchTableViewCell.swift
//  Talent Cash
//
//  Created by MacBook Pro on 21/09/2022.
//

import UIKit

class DiscoverySearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var videoImage: UIImageView!
    var hashTags:Hashtag! {
        didSet{
            setHashTags()
        }
    }
    var user:User! {
        didSet{
            setUser()
        }
    }
    private func setHashTags() {
        userLabel.text = hashTags.hashtag
        videoImage.image = .init(named: "hash")
        descLabel.isHidden = true
        playImageView.image = .init(named: "video")
    }
    private func setUser() {
        userLabel.text = user.name
        videoImage.sd_setImage(with: URL(string: user.profileImage ), placeholderImage: UIImage(named: "placeholder.user")!)
        descLabel.text = user.email ?? ""
        playImageView.image = .init(named: "video")
    }
}
