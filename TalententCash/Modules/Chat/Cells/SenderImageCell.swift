//
//  SenderImageCell.swift
//  Talent Cash
//
//  Created by MacBook Pro on 24/09/2022.
//

import UIKit

class SenderImageCell: UITableViewCell {
    
    @IBOutlet weak var snd_image: UIImageView!
    @IBOutlet weak var sndImageTime: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var btnDateSection: UIButton!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
