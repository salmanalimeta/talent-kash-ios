//
//  CommentCollectionViewCell.swift
//  Talent Cash
//
//  Created by MacBook Pro on 14/09/2022.
//

import UIKit
import SDWebImage

class CommentCollectionViewCell:UICollectionViewCell{
    
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var usernameLabel: UILabel!
    @IBOutlet weak private var profileImage: UIImageView!
    @IBOutlet weak private var commentLabel: UILabel!
    var arrComments :comment! {
        didSet{
            setCommentData()
        }
    }
    private func setCommentData() {

        
        commentLabel.text = arrComments?.comment
        usernameLabel.text = arrComments?.name
        timeLabel.text = arrComments?.time
        
        let userImgUrl = URL(string: arrComments?.image ?? "")
        self.profileImage.sd_setImage(with: userImgUrl, placeholderImage: UIImage(named: "placeholder.user"))
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        profileImage.borderColor = UIColor(named: "buttonArcFirstColor")!
        profileImage.borderWidth = 2

    }
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
            layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return layoutAttributes
        }
    @IBAction func comentLikeButtonTap(_ sender: UIButton) {
        
    }
    @IBAction func replayButtonTap(_ sender: UIButton) {
    }
}
