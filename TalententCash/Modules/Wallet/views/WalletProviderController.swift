//
//  WalletProviderController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 11/10/2022.
//

import UIKit

class WalletProviderController: StatusBarController {
    
    var completeDataSource : [CompletedBookingList] = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataFound: UILabel!

    @IBOutlet weak var totalEarning: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "CompletedCell", bundle: .main), forCellWithReuseIdentifier: "CompletedCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        totalEarnings()
        completedList()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func completedList() {
        self.startPulseAnimation()
        NetworkUtil.request(dataType: CompletedBookingTalentResponse.self, apiMethod:  Constants.URL.completedBookingListTalent+(UserDefaultManager.instance.userID), parameters: nil) { data in
            self.stopPulseAnimation()
                self.completeDataSource = data.completedBookingList
            
            if self.completeDataSource.count > 0{
                self.noDataFound.alpha = 0
            }else{
                
                self.noDataFound.alpha = 1
            }
                
                self.collectionView.reloadData()
                
            } onFailure: { _,error in
                self.stopPulseAnimation()
                self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            }
        }
    
    
    func totalEarnings() {
  
        NetworkUtil.request(dataType: ProviderEarningModel.self, apiMethod:  Constants.URL.talentProviderTotalEarning+(UserDefaultManager.instance.userID), parameters: nil) { data in
           
            if data.status == true{
                
                self.totalEarning.text = "\(data.totalEarning ?? 0) PKR"
            }
                
            } onFailure: { _,error in
                self.stopPulseAnimation()
                self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            }
        }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension WalletProviderController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let obj = self.completeDataSource[indexPath.row]
        let vc = UIStoryboard.init(name: "Booking", bundle: nil).instantiateViewController(withIdentifier: "InvoiceViewController") as! InvoiceViewController
        vc.modalPresentationStyle = .fullScreen
        vc.bookingId = obj._id
        self.present(vc, animated: true)
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return completeDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CompletedCell.self)
     
            cell.setupCompleteCell(model: self.completeDataSource[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.width - 30, height: 70)
    }
    
}
