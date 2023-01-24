//
//  DiscoveryTableViewCell.swift
//  Talent Cash
//
//  Created by MacBook Pro on 16/09/2022.
//

import UIKit

class DiscoveryTableViewCell: UITableViewCell {
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var hashtagImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    private var _item:Hashtag!
    var onViewAllClick:((Hashtag)->Void) = {_ in }
    var videoLikeHandle:((Reel)->Void) = {_ in }
    var item:Hashtag {
        set(v){
            self._item = v
            setData()
        }
        get{
            self._item
        }
    }

    private func setData() {
        collectionView.dataSource = self
        collectionView.delegate = self
        self.hashtagLabel.text = _item.hashtag
        collectionView.reloadData()
    }
    @IBAction func viewAllClick(_ sender: Any) {
        self.onViewAllClick(self.item)
    }
}

extension DiscoveryTableViewCell:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let context = UIApplication.topViewController()
        let vc = context?.storyboard?.instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
        vc.reels = _item.reel
        vc.userSpecificReels = true
        vc.fixedReels = true
        vc.selectedIndex = indexPath.row
        vc.videoLikeHandle = {reel in
            if let i = self._item.reel.firstIndex(where: {$0._id == reel._id}){
                self._item.reel.remove(at: i)
                self._item.reel.insert(reel, at: i)
                self.collectionView.reloadItems(at: [.init(row: i, section: 0)])
                self.videoLikeHandle(reel)
            }
        }
        context?.present(vc , animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let n = item.reel.count
        return n > 5 ? 5 : n
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width*0.3, height: collectionView.frame.width*0.44)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! VideoImageCell
        cell.setupUIData(model:(self._item.reel[indexPath.row]))
        return cell
    }
}
