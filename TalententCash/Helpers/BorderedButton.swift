//
//  BorderedButton.swift
//  wallet_module
//
//  Created by MacBook Pro on 06/10/2022.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    
    let borderLayer: CAGradientLayer = {
        let borderLayer = CAGradientLayer()
        borderLayer.type = .axial
        borderLayer.colors = [UIColor(named: "ButtonGradientStart")?.cgColor ?? UIColor.init(red:176/255, green: 56/255, blue: 205/255, alpha: 1.0).cgColor,UIColor(named: "primary")?.cgColor ?? UIColor.init(red:218/255, green: 56/255, blue: 106/255, alpha: 1.0).cgColor]
        borderLayer.startPoint = CGPoint(x: 0, y: 1)
        borderLayer.endPoint = CGPoint(x: 1, y: 0)
        borderLayer.locations = [0,1]
        borderLayer.cornerRadius = 5
        return borderLayer
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        borderLayer.frame = bounds
        let mask = CAShapeLayer()
        let rect = bounds.insetBy(dx: 1, dy: 1)
        mask.path = UIBezierPath(roundedRect: rect, cornerRadius: 4).cgPath
        mask.lineWidth = 1.4
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        borderLayer.mask = mask
    }
}

private extension BorderedButton {
    func configure() {
        
        layer.addSublayer(borderLayer)
    }
}
