//
//  DiscoveryCaraouselCollectionView.swift
//  Talent Cash
//
//  Created by MacBook Pro on 15/09/2022.
//

import UIKit

class DiscoveryCaraouselCollectionView: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        dataSource = self
        self.contentInset = .init(top: 0, left: 0, bottom: 10, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
    }

}
