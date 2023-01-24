//
//  StatusBarController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 06/10/2022.
//

import UIKit

class StatusBarController: UIViewController {
    var fullScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if fullScreen {
            let statusBarBackgroungView = UIView()
            statusBarBackgroungView.translatesAutoresizingMaskIntoConstraints = false
            statusBarBackgroungView.backgroundColor = UIColor(named: "toolBarBackground")!
            view.addSubview(statusBarBackgroungView)
            NSLayoutConstraint.activate([
                statusBarBackgroungView.leftAnchor.constraint(equalTo: view.leftAnchor),
                statusBarBackgroungView.topAnchor.constraint(equalTo: view.topAnchor),
                statusBarBackgroungView.rightAnchor.constraint(equalTo: view.rightAnchor),
                statusBarBackgroungView.heightAnchor.constraint(equalToConstant: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            ])
        }
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopPulseAnimation()
    }
}
