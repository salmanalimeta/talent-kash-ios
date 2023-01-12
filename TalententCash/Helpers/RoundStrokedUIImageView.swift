//
//  RoundStrokedUIImageView.swift
//  Talent Cash
//
//  Created by MacBook Pro on 07/10/2022.
//

import UIKit

@IBDesignable
class RoundStrokedUIImageView: UIImageView {
    // For item created programmatically
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGradientsToImageView()
    }
    
    // For items created in the storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGradientsToImageView()
    }
    
    func addGradientsToImageView() {
        let m = CAShapeLayer()
        m.path = UIBezierPath(ovalIn:bounds.insetBy(dx: 1, dy: 1)).cgPath
        layer.mask = m
    }
}
