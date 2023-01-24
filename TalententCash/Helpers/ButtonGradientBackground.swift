//
//  ButtonGradientBackground.swift
//  Talent Cash
//
//  Created by MacBook Pro on 19/09/2022.
//

import UIKit

@IBDesignable
class ButtonGradientBackground: UIButton {
    @IBInspectable var backgroundGradient : Bool = true {
        didSet{
            if backgroundGradient {
                configure()
            }else{
                borderLayer.removeFromSuperlayer()
            }
        }
    }
    @IBInspectable var layerTransparent : CGFloat = 1.0 {
       didSet{
           borderLayer.colors = [(UIColor(named: "ButtonGradientStart") ?? UIColor.systemPink).withAlphaComponent(layerTransparent).cgColor,(UIColor(named: "primary") ?? UIColor.systemPink).withAlphaComponent(layerTransparent).cgColor]
        }
    }
   lazy var borderLayer: CAGradientLayer = {
        let borderLayer = CAGradientLayer()
        borderLayer.type = .axial
       borderLayer.colors = [(UIColor(named: "ButtonGradientStart") ?? UIColor.systemPink).cgColor,(UIColor(named: "primary") ?? UIColor.systemPink).cgColor]
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
    }
}

private extension ButtonGradientBackground {
    func configure() {
        layer.insertSublayer(borderLayer, at: 0)
    }
}

