//
//  MyCoinTableViewCell.swift
//  wallet_module
//
//  Created by MacBook Pro on 06/10/2022.
//

import UIKit

class MyCoinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playDescStack: UIStackView!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var coinLabel: UILabel!
    
    override func layoutSubviews() {
          super.layoutSubviews()
          contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
          contentView.layer.cornerRadius = 5
    }
}
