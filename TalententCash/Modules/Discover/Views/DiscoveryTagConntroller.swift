//
//  DiscoveryTagConntroller.swift
//  Talent Cash
//
//  Created by MacBook Pro on 15/09/2022.
//

import UIKit

class DiscoveryTagController: StatusBarController {
    @IBOutlet weak var tagTitle: UILabel!
    @IBOutlet weak var tagCommentCounter: UILabel!
    @IBOutlet weak var videoCounter: UILabel!
    @IBOutlet weak var tagImage: UIImageView!
    @IBOutlet weak var tagCoverImage: UIImageView!
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var tag:Hashtag!
    var videoLikeHandle:(Reel)->Void = {_ in }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        self.tagTitle.text = tag.hashtag
        self.videoCounter.text = "\(tag.videoCount)"
        self.likeCounter.text = "\(tag.likes)"
        self.tagCommentCounter.text = "\(tag.comments)"
        self.tagCoverImage.sd_setImage(with: URL(string: tag?.coverImage ?? ""))
    }
    @IBAction func backClick(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func shotClick(_ sender: UIButton) {
    }
}

extension DiscoveryTagController :UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeVideoViewController") as! HomeVideoViewController
        vc.reels = tag.reel
        vc.userSpecificReels = true
        vc.fixedReels = true
        vc.selectedIndex = indexPath.row
        vc.videoLikeHandle = {reel in
            if let i = self.tag.reel.firstIndex(where: {$0._id == reel._id}){
                self.tag.reel.remove(at: i)
                self.tag.reel.insert(reel, at: i)
                self.collectionView.reloadItems(at: [.init(row: i, section: 0)])
                self.videoLikeHandle(reel)
            }
        }
        UIApplication.topViewController()?.present(vc , animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tag.reel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! VideoImageCell
        cell.setupUIData(model: (self.tag.reel[indexPath.row]))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width*0.3, height: collectionView.frame.width*0.45)
    }
}
