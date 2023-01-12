//
//  GiftCollectionViewCell.swift
//  Talent Cash
//
//  Created by MacBook Pro on 14/09/2022.
//

import UIKit

class GiftCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var giftImage: UIImageView!
    @IBOutlet weak var coinLabel: UILabel!
    
    func setData() {
        self.coinLabel.text = "35 Coins"
    }
}
