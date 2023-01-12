//
//  DiscoveryCarouselCell.swift
//  Talent Cash
//
//  Created by MacBook Pro on 16/09/2022.
//

import UIKit

class DiscoveryCarouselCell: UITableViewCell {
    @IBOutlet weak var collectionViewSliderImages: UICollectionView!
    @IBOutlet weak var sliderPageController: UIPageControl!
    
    func setData() {
        collectionViewSliderImages.dataSource = self
        collectionViewSliderImages.delegate  = self
        sliderPageController.numberOfPages = 3
        self.startTimer()
    }
    
    func startTimer() {

        let timer =  Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }
    
    @objc func scrollAutomatically(_ timer1: Timer) {

        if let coll  = collectionViewSliderImages {
            for cell in coll.visibleCells {
                let indexPath: IndexPath? = coll.indexPath(for: cell)
                if ((indexPath?.row)! < 3 - 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                    coll.scrollToItem(at: indexPath1!, at: .right, animated: true)
                    sliderPageController.currentPage = indexPath1?.row ?? 0
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    coll.scrollToItem(at: indexPath1!, at: .left, animated: true)
                    sliderPageController.currentPage = indexPath1?.row ?? 0
                }

            }
        }
    }
}

extension DiscoveryCarouselCell:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       return .init(width: collectionView.frame.width, height: collectionView.frame.width*0.6)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "carouselCell", for: indexPath) as! DiscoveryCollectioCarouselCell
        cell.image.image = .init(named: "banner\(indexPath.row+1)")
        return cell
       
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        sliderPageController.currentPage = page
    }
}
