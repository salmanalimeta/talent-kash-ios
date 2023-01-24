//
//  ProfileVideoCell.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 14/09/2022.
//

import UIKit
import Reusable
import SDWebImageFLPlugin
import NVActivityIndicatorView

class VideoImageCell: UICollectionViewCell {
    
    @IBOutlet weak var videoImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        videoImage.backgroundColor = .black
    }

    func setupUIData(model: Reel) {
        let lv = NVActivityIndicatorView(frame: .zero)
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.type = .circleStrokeSpin
        lv.color = UIColor.init(named: "primary") ?? UIColor.systemPink
        videoImage.addSubview(lv)
        NSLayoutConstraint.activate([
            lv.centerXAnchor.constraint(equalTo: videoImage.centerXAnchor),
            lv.centerYAnchor.constraint(equalTo: videoImage.centerYAnchor),
            lv.widthAnchor.constraint(equalTo: videoImage.widthAnchor, multiplier: 0.5),
            lv.heightAnchor.constraint(equalTo: videoImage.widthAnchor, multiplier: 0.5),
        ])
        lv.startAnimating()
        videoImage.sd_setImage(with: URL(string:model.thumbnail ?? "")){_,_,_,_ in
            lv.stopAnimating()
            lv.removeFromSuperview()
        }
    }
}


