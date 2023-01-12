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

struct BookingModel {
    let quantity: Int
    let price: Int
}

class BookingProviderController: StatusBarController {
    
    
    @IBOutlet weak var widthConststraintReceiptButton: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintViewButton: NSLayoutConstraint!
    @IBOutlet weak var sheet: UIView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataFound: UIView!
    @IBOutlet weak var activeBtn: UIButton!
    @IBOutlet weak var completedBtn: UIButton!
    
    @IBOutlet weak var viewDetailButton: ButtonGradientBackground!
    @IBOutlet weak var viewReceiptButton: ButtonGradientBackground!
    @IBOutlet weak var offerIdLable: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    var activeDataSource : [ActiveBooking] = []
    var completeDataSource : [CompletedBookingList] = []
    //0 for active and 1 for completed
    var activeState = true
    var talentUserComplete:CompletedBookingList!
    var talentUserActive:ActiveBooking!
    private var blurView:UIView? = nil
    private var isBusy = false
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyLabel.isHidden = true
        collectionView.register(UINib(nibName: "CompletedCell", bundle: .main), forCellWithReuseIdentifier: "CompletedCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        activeBtn.setTitle("", for: .normal)
        completedBtn.setTitle("", for: .normal)
        activeList()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("BOOKING_COMPLETED"), object: nil, queue: .main) { _ in
            self.activeList(callFromNotification: true)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(NSNotification.Name("BOOKING_COMPLETED"))
    }
    override func viewDidDisappear(_ animated: Bool) {
        blurView?.removeFromSuperview()
        blurView = nil
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CompleteOrderProviderController"{
            (segue.destination as! CompleteOrderProviderController).bookingOrderSummary = talentUserActive
        }
        if segue.identifier == "InvoiceProviderController" {
            (segue.destination as! InvoiceProviderController).bookId = talentUserComplete._id
        }
    }
    
    @IBAction func viewRecieptButtonClick(_ sender: Any) {
        sheet.isHidden = true
        self.performSegue(withIdentifier: "InvoiceProviderController", sender: self)
    }
    
    @IBAction func viewDetailButtonClick(_ sender: Any) {
        sheet.isHidden = true
        self.performSegue(withIdentifier: "CompleteOrderProviderController", sender: self)
    }
    
    @IBAction func activeAct(_ sender: Any) {
        if isBusy {
            return
        }
        isBusy = true
        activeState = true
        activeBtn.setImage(UIImage.init(named: "ActiveSelected"), for: .normal)
        completedBtn.setImage(UIImage.init(named: "CompletedUnselect"), for: .normal)
        activeList()
    }
    
    @IBAction func completedAct(_ sender: Any) {
        if isBusy {
            return
        }
        isBusy = true
        activeState = false
        activeBtn.setImage(UIImage.init(named: "ActiveUnselect"), for: .normal)
        completedBtn.setImage(UIImage.init(named: "CompletedSelected"), for: .normal)
        activeList()
    }
    private func setVisbilityViewDetailButton(visibilty:Bool){
        viewDetailButton.isHidden = !visibilty
        heightConstraintViewButton.constant = visibilty ? 36 : 0
    }
    private func setVisbilityViewReeceiptButton(visibilty:Bool){
        if visibilty{
            viewReceiptButton.isHidden = false
            widthConststraintReceiptButton.constant = 100
        }else{
            viewReceiptButton.isHidden = true
            widthConststraintReceiptButton.constant = 0
        }
    }
    func activeList(callFromNotification:Bool = false) {
        if !callFromNotification{
            self.startPulseAnimation()
        }
        if self.activeState {
            NetworkUtil.request(dataType: ActiveBookingTalentRespond.self , apiMethod: Constants.URL.activeTalentList + (UserDefaultManager.instance.userID), parameters: nil) { data in
                self.stopPulseAnimation()
                self.activeDataSource = data.activeBookingList
                self.emptyLabel.isHidden = !data.activeBookingList.isEmpty
                self.collectionView.reloadData()
                self.isBusy = false
            } onFailure: { _,error in
                self.isBusy = false
                self.stopPulseAnimation()
                self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            }
        }else{
            NetworkUtil.request(dataType: CompletedBookingTalentResponse.self, apiMethod:  Constants.URL.completedBookingListTalent+(UserDefaultManager.instance.userID), parameters: nil) { data in
                self.stopPulseAnimation()
                self.completeDataSource = data.completedBookingList
                self.emptyLabel.isHidden = !data.completedBookingList.isEmpty
                self.collectionView.reloadData()
                self.isBusy = false
            } onFailure: { _,error in
                self.isBusy = false
                self.stopPulseAnimation()
                self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            }
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        dismiss(animated: false)
    }
    private func setViewDetails(index:Int){
        if activeState {
            self.talentUserActive = activeDataSource[index]
            nameLabel.text = activeDataSource[index].userId?.name
            offerIdLable.text = activeDataSource[index].booking_id
            serviceName.text = activeDataSource[index].service
            servicePrice.text = "\(activeDataSource[index].price) PKR"
            serviceDescription.text = activeDataSource[index].activeBookingListDescription
            
        }else{
            self.talentUserComplete  = completeDataSource[index]
            nameLabel.text = completeDataSource[index].userId.name
            offerIdLable.text = completeDataSource[index].booking_id
            serviceName.text = completeDataSource[index].service
            servicePrice.text = "\(completeDataSource[index].price) PKR"
            serviceDescription.text = completeDataSource[index].description
        }
        setVisbilityViewDetailButton(visibilty:activeState)
        setVisbilityViewReeceiptButton(visibilty:!activeState)
        sheet.isHidden = false
        view.bringSubviewToFront(sheet)
    }
}

extension BookingProviderController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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
            cell.setupActiveCell(model: self.activeDataSource[indexPath.row])
        } else {
            cell.setupCompleteCell(model: self.completeDataSource[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.width - 30, height: 70)
    }
    
}

extension BookingProviderController {
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
