//
//  completeOrderProviderController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 29/09/2022.
//

import UIKit

class CompleteOrderProviderController:UIViewController{
    
    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var assignedUsernameLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var acceptDateLabel: UILabel!
    
    var bookingOrderSummary:ActiveBooking!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
//       loadData()
    }
//    private func loadData(){
//        UIViewController.displaySpinner(onView: view)
//        NetworkUtil.request(dataType: trackTalentProviderOrderSummaryResponse.self, apiMethod: Constants.URL.trackTalentProviderOrderSummary, parameters: nil) { data in
//            self.stopPulseAnimation()
//            self.bookingOrderSummary = data.booking
//            self.setData()
//        } onFailure: { error in
//            self.stopPulseAnimation()
//            self.showToast(message: error, font: .systemFont(ofSize: 16))
//        }
//    }
    @IBAction func backButtonClick(_ sender: Any) {
        dismiss(animated: true)
    }
    private func setData(){
        self.serviceNameLabel.text = bookingOrderSummary.service
        self.assignedUsernameLabel.text = bookingOrderSummary.service
        self.acceptDateLabel.text = bookingOrderSummary.accept_date
        self.servicePriceLabel.text = "\(bookingOrderSummary.price) PKR"
    }
    
    @IBAction func completeOrderClick(_ sender: Any) {
        self.startPulseAnimation()
        NetworkUtil.request(dataType: CompleteTalentProviderOrderResponse.self, apiMethod: Constants.URL.completeTalentProviderOrder+bookingOrderSummary._id, parameters: nil) { data in
            self.stopPulseAnimation()
            self.openSuccessController(orderId:data.booking._id   ,earnAmount:"\(data.booking.price)")
            NotificationCenter.default.post(name: NSNotification.Name("BOOKING_COMPLETED"), object: nil)
        } onFailure: { _,msg in
            self.stopPulseAnimation()
            self.showToast(message: msg, font:  .boldSystemFont(ofSize: 16))
        }
    }
    private func openSuccessController(orderId:String,earnAmount:String){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderSuccessfullProviderController") as! OrderSuccessfullProviderController
        vc.earnAmount = earnAmount
        vc.bookingId = orderId
        self.present(vc, animated: true)
    }
}
