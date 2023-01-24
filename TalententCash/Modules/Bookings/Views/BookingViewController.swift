//
//  BookingViewController.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 28/09/2022.
//

import UIKit
import Foundation
import Alamofire
import SafariServices
import SwiftUI

//struct BookingModel {
//    let quantity: Int
//    let price: Int
//}

class BookingViewController: StatusBarController {
    
    
    @IBOutlet weak var sheet: UIView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activeBtn: UIButton!
    @IBOutlet weak var completedBtn: UIButton!
    
    @IBOutlet weak var viewReceiptButton: ButtonGradientBackground!
    
    @IBOutlet weak var viewtrackButton: ButtonGradientBackground!
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var offerIdLable: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    private var blurView:UIView? = nil
    var bookingId: String!
    private var activeDataSource : [ActiveBookingList] = []
    private var completeDataSource : [CompleteBookingList] = []
    private var selectedActiveOrder:ActiveBookingList!
    //0 for active and 1 for completed
    private var activeState = true
    private var feedbackAdded: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "CompletedCell", bundle: .main), forCellWithReuseIdentifier: "CompletedCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        activeBtn.setTitle("", for: .normal)
        completedBtn.setTitle("", for: .normal)
        activeList()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("BOOKING_FEEDBACK_ADDED"), object: nil, queue: .main) { _ in
            self.activeList()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(NSNotification.Name("BOOKING_FEEDBACK_ADDED"))
    }
    override func viewDidDisappear(_ animated: Bool) {
        blurView?.removeFromSuperview()
        blurView = nil
        sheet.isHidden = true
    }
    
    @IBAction func activeAct(_ sender: Any) {
        activeState = true
        activeBtn.setImage(UIImage.init(named: "ActiveSelected"), for: .normal)
        completedBtn.setImage(UIImage.init(named: "CompletedUnselect"), for: .normal)
        activeList()
    }
    
    @IBAction func completedAct(_ sender: Any) {
        activeState = false
        activeBtn.setImage(UIImage.init(named: "ActiveUnselect"), for: .normal)
        completedBtn.setImage(UIImage.init(named: "CompletedSelected"), for: .normal)
        activeList()
    }
    
    func activeList() {
        self.startPulseAnimation()
        if self.activeState {
            NetworkUtil.request(dataType: ActiveModel.self , apiMethod:  Constants.URL.activeList+UserDefaultManager.instance.userID, parameters: nil) { [self] data in
                self.stopPulseAnimation()
                self.activeDataSource = data.activeBookingList
                self.collectionView.reloadData()
                self.emptyLabel.isHidden = !data.activeBookingList.isEmpty
            } onFailure: { _,error in
                self.emptyLabel.isHidden = !self.activeDataSource.isEmpty
                self.stopPulseAnimation()
                self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            }
        }else{
            NetworkUtil.request(dataType: CompleteModel.self, apiMethod:Constants.URL.completeList+UserDefaultManager.instance.userID, parameters: nil) { data in
                self.stopPulseAnimation()
                self.completeDataSource = data.completeBookingList
                self.collectionView.reloadData()
                self.emptyLabel.isHidden = !data.completeBookingList.isEmpty
            } onFailure: { _,error in
                self.emptyLabel.isHidden = !self.completeDataSource.isEmpty
                self.stopPulseAnimation()
                self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            }
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
    private func setViewDetails(index:Int){
        if activeState {
            selectedActiveOrder = activeDataSource[index]
            nameLabel.text = activeDataSource[index].talentUserID?.name
            offerIdLable.text = activeDataSource[index].booking_id
            serviceName.text = activeDataSource[index].service
            servicePrice.text = "\(activeDataSource[index].price) PKR"
            serviceDescription.text = activeDataSource[index].activeBookingListDescription
            viewReceiptButton.isHidden = true
            viewtrackButton.setTitle("Track Order", for: .normal)
            
        }else{
            feedbackAdded = completeDataSource[index].isFeedbackAdd
            bookingId = completeDataSource[index].id
            nameLabel.text = completeDataSource[index].talentUserID.name
            offerIdLable.text = completeDataSource[index].booking_id
            serviceName.text = completeDataSource[index].service
            servicePrice.text = "\(completeDataSource[index].price) PKR"
            serviceDescription.text = completeDataSource[index].completeBookingListDescription
            viewReceiptButton.isHidden = false
            viewtrackButton.setTitle(feedbackAdded ? "View Feedback" : "Give Feedback", for: .normal)
        }
        
        sheet.isHidden = false
        view.bringSubviewToFront(sheet)
    }
    
    @IBAction func viewReciptBtn(_ sender: Any) {
        showInvoice()
    }
    
    func showInvoice() {
        let st:UIStoryboard = UIStoryboard(name: "Booking", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
        vc.bookingId = bookingId
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func giveFeedbackBtn(_ sender: Any) {
        if activeState{
            let vc = UIStoryboard.init(name: "HireMe", bundle: nil).instantiateViewController(withIdentifier: "TrackController") as! TrackController
            vc.name = selectedActiveOrder.talentUserID?.name ?? ""
            vc.remainingPrice = "\(selectedActiveOrder.remainingPrice)"
            vc.initPrice = "\(selectedActiveOrder.initialPrice)"
            vc.userImage = selectedActiveOrder.talentUserID?.profileImage ?? ""
            vc.bookingID = selectedActiveOrder.booking_id ?? "0"
            vc.serviceValue = selectedActiveOrder.service
            vc.sPrice = "\(selectedActiveOrder.price)"
            vc.otherId = selectedActiveOrder.talentUserID?.id ?? "0"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }else{
            let vc = UIStoryboard.init(name: "Booking", bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            vc.bookingId = bookingId
            vc.feedback = feedbackAdded
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        sheet.isHidden = true
        blureToggle()
    }
}

extension BookingViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        blureToggle(selector:#selector(blurClick))
        setViewDetails(index: indexPath.row)
        
    }
    @objc func blurClick(sender:UITapGestureRecognizer){
        blureToggle()
        sheet.isHidden = true
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        activeState ? activeDataSource.count : completeDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CompletedCell.self)
        if activeState  {
            //cell.setupActiveCell(model: self.activeDataSource[indexPath.row])
            let obj = self.activeDataSource[indexPath.row]
            cell.userName.text = obj.talentUserID?.name
            cell.serviceId.text = obj.booking_id
        } else {
            //cell.setupCompleteCell(model: self.completeDataSource[indexPath.row])
            
            let obj = self.completeDataSource[indexPath.row]
            cell.userName.text = obj.talentUserID.name
            cell.serviceId.text = obj.booking_id
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.width - 30, height: 70)
        
    }
    
}
extension BookingViewController {
    func blureToggle(_ style: UIBlurEffect.Style = .light,selector:Selector? = nil) {
        if blurView == nil {
            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if let selector = selector{
                blurEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:selector))
            }
            view.addSubview(blurEffectView)
            blurView = blurEffectView
        }else{
            blurView?.removeFromSuperview()
            blurView = nil
        }
    }
}

