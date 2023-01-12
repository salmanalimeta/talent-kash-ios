//
//  WalletWebViewVC.swift
//  Talent Cash
//
//  Created by MacBook Pro on 07/10/2022.
//

import UIKit
import WebKit

class WalletWebViewVC: StatusBarController,WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var myURL:String = ""

    private var isRootPage = true
    override func viewDidLoad() {
        super.viewDidLoad()
  
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        let request = URLRequest(url: URL(string: myURL)!)
        self.webView.load(request)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        if isRootPage{
            self.dismiss(animated: true)
        }
        webView.goBack()
        isRootPage = true
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
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

            print("didStartProvisionalNavigation = ", navigation.debugDescription)
        print("didStartProvisionalNavigation url = ", webView.url)
    }
    @available(iOS 14.5, *)
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
                    return
                }
            print("navigationAction = ",urlAsString)
                if urlAsString.range(of: "the url that the button redirects the webpage to") != nil {
                // do something
                }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")

        if let url = webView.url?.absoluteString{
            print("url = \(url)")
            
            if url.contains("status"){
               
                let fullNameArr = url.components(separatedBy: "?")

                let val2 = fullNameArr[1]
                
                let val3 = val2.components(separatedBy: "&")
                
                let val4 = val3[0]
                
                if (val4 == "status=Success"){
                    self.dismiss(animated: true)
                    NotificationCenter.default.post(name: Notification.Name("paymentStatus"), object: nil, userInfo: ["status":"Success"])
                  
                }else{
                    self.dismiss(animated: true)
                    NotificationCenter.default.post(name: Notification.Name("paymentStatus"), object: nil, userInfo: ["status":"Fail"])
                }
            }
        }
    }
}

// MARK: UIDelegate method implemenations
extension WalletWebViewVC :WKUIDelegate{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //Load HTML links with 'target="_blank"'
        if navigationAction.targetFrame == nil{
            self.isRootPage = false
            webView.load(navigationAction.request)
        }
        return nil
    }
}
