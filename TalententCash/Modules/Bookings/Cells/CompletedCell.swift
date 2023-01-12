//
//  PastOrderCell.swift
//  Fresh Box
//
//  Created by Zohaib Baig on 31/05/2022.
//

import UIKit
import Reusable

class CompletedCell: UICollectionViewCell, NibReusable {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var serviceId: UILabel!
    @IBOutlet weak var backView: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
     }
     
     func setupUI(){
         backView.layer.cornerRadius = 8
     }
    
    func setupActiveCell(model: ActiveBooking) {
        userName.text = model.userId?.name
        serviceId.text = model.booking_id
    }
    func setupCompleteCell(model: CompletedBookingList) {
        userName.text = model.userId.username
        serviceId.text = model.booking_id
    }

    @IBAction func viewDetailsBtn(_ sender: Any) {
//        summaryCallBack?(self)
    }
}
