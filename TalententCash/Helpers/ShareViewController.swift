//
//  ShareViewController.swift
//  Talent Cash
//
//  Created by Aamir on 18/09/2022.
//

import UIKit

class ShareViewController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        return .init(origin: .init(x: 0, y: bounds.midY), size: .init(width: bounds.width, height: bounds.height/2))
    }
}
