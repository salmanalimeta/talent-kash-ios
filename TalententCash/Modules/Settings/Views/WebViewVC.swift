//
//  WebViewVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 04/10/2022.
//

import UIKit
import WebKit

class WebViewVC: StatusBarController {
    
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var navTite:String = ""
    var myURL:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = navTite
        
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        let request = URLRequest(url: URL(string: myURL)!)
        self.webView.load(request)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "loading" {
                if webView.isLoading {
                    activityIndicator.startAnimating()
                    activityIndicator.isHidden = false
                } else {
                    activityIndicator.stopAnimating()
                }
            }
        }
    
    
    

}
