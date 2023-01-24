//
//  SeetingSwitchCell.swift
//  Talent Cash
//
//  Created by MacBook Pro on 04/10/2022.
//

import UIKit

class SeetingSwitchCell: UITableViewCell {

    @IBOutlet weak var settingLable: UILabel!
    @IBOutlet weak var userSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
