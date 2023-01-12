//
//  MyTransactionHistoryTableViewCell.swift
//  wallet_module
//
//  Created by MacBook Pro on 06/10/2022.
//

import UIKit

class MyTransactionHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var boughtCoinLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func layoutSubviews() {
          super.layoutSubviews()
          contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
          contentView.layer.cornerRadius = 5
    }
}
