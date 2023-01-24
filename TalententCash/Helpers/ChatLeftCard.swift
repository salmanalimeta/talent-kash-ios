//
//  ChatLeftCard.swift
//  Talent Cash
//
//  Created by MacBook Pro on 22/09/2022.
//

import UIKit

@IBDesignable
class ChatLeftCard : UIView {

    @IBInspectable var ChatDirectionLeft:Bool = true
    @IBInspectable var cardBackgroud: UIColor = .systemGray
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        var rectPath:UIBezierPath
        let minDistance = 20.0
        if ChatDirectionLeft {
            rectPath = UIBezierPath(roundedRect: .init(x: bounds.minX+minDistance, y: bounds.minY, width: bounds.size.width-minDistance, height: bounds.size.height), cornerRadius: minDistance/2)
            rectPath.stroke()
            rectPath.move(to: bounds.origin)
            rectPath.addLine(to: .init(x: bounds.minX+minDistance*2, y: bounds.minY))
            rectPath.addLine(to: .init(x: bounds.minX+minDistance, y: bounds.minY+minDistance))
            rectPath.addLine(to: bounds.origin)
        }else{
            let shape = UIBezierPath()
            shape.move(to: .init(x: bounds.maxX, y: bounds.minY))
            shape.addLine(to: .init(x: bounds.maxX - (minDistance*2), y: bounds.minY))
            shape.addLine(to: .init(x: bounds.maxX - (minDistance*2), y: bounds.minY +  (minDistance*2)))
            shape.addLine(to: .init(x: bounds.maxX, y: bounds.minY))
            cardBackgroud.set()
            shape.fill()
            rectPath = UIBezierPath(roundedRect: .init(x: bounds.minX, y: bounds.minY, width: bounds.size.width-minDistance, height: bounds.size.height), cornerRadius: minDistance/2)
            rectPath.stroke()
            
        }
        rectPath.close()
        cardBackgroud.set()
        rectPath.fill()
    }
}
