//
//  extention.swift
//  Talent_Cash_App
//
//  Created by Aamir on 08/09/2022.
//

import UIKit
import NVActivityIndicatorView

var activityIndicator : NVActivityIndicatorView!

private var animationView:UIView? = nil

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController

            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIViewController {
    func showToast(message : String, font: UIFont = .systemFont(ofSize: 16, weight: .bold)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 175, y: self.view.frame.size.height*0.12, width: 350, height: 40))
        //    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.backgroundColor = #colorLiteral(red: 0.3129099309, green: 0.3177284598, blue: 0.3219906092, alpha: 0.8590539384)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 2;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay:2, options: .curveLinear, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    class func displaySpinner(onView : UIView) {
        
        let xAxis = (onView.frame.size.width / 2) // or use (view.frame.size.width / 2) // or use (faqWebView.frame.size.width / 2)
        let yAxis = (onView.frame.size.height / 2)


        let frame = CGRect(x: xAxis-20, y: yAxis-20, width: 45, height: 45)
        activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.type = .circleStrokeSpin // add your type
        if #available(iOS 11.0, *) {
            activityIndicator.color = UIColor.init(named: "buttonArcSecondColor") ?? UIColor.gray
        } else {
            // Fallback on earlier versions
        }

        onView.addSubview(activityIndicator) // or use  webView.addSubview(activityIndicator)
        activityIndicator.startAnimating()

    }

    class func removeSpinner() {
        DispatchQueue.main.async {
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
        }
    }
    
    func startPulseAnimation(){
        if animationView != nil {
            return
        }
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 0.1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        pulseAnimation.autoreverses = false
        
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 1
        
        pulse1.fromValue = 0.2
        pulse1.toValue = 1
        pulse1.autoreverses = false
//        pulse1.damping = 1

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse1,pulseAnimation]
        let size = view.bounds.width*0.2
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(ovalIn: .init(origin: .zero, size: .init(width: size, height: size))).cgPath
        let av = UIView(frame:.init(origin: .init(x: view.center.x-(size/2), y: view.center.y-(size/2)), size: .init(width: size, height: size)))
        av.layer.mask = shape
        av.backgroundColor = .systemPink
        av.layer.add(animationGroup, forKey: nil)
        view.addSubview(av)
        animationView = av
    }
    func stopPulseAnimation(){
        animationView?.layer.removeAllAnimations()
        animationView?.removeFromSuperview()
        animationView = nil
    }
}

extension UIButton {
    
    func alignImageTop(spacing:CGFloat = 2,paddingBttom:CGFloat = 0) {
      
       guard let imageSize = self.imageView?.image?.size,
                   let text = self.titleLabel?.text,
                   let font = self.titleLabel?.font
                   else { return }
               self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
       let titleSize = NSString(string: text).size(withAttributes: [kCTFontAttributeName as NSAttributedString.Key: font])
               self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
               let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
               self.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom:paddingBttom + edgeOffset, right: 0.0)
       }
    }
extension String {
    func shorten() -> String{
        guard let number = Double(self)else{
            return ""
        }
        if number < 1000{
            return "\(self)"
        }else if number < 1000000{
            return "\(number/1000)K"
        }else{
            return "\(round(number/100000))M"
        }
    }
    var encodeURL: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func addParams(params: [String]) -> String {
        var count = 1
        var newURL = self
        for param in params {
            newURL = newURL.replacingOccurrences(of: "*param\(count)*", with: param.encodeURL)
            count += 1
        }
        return newURL
    }
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
          let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
          let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [.font : font], context: nil)
          return actualSize.height
      }
}

public extension UIView {
    
    private static let kLayerNameGradientBorder = "GradientBorderLayer"
    
    func setGradientBorder(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
    ) {
        let existedBorder = gradientBorderLayer()
        let border = existedBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: 0).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width
        
        border.mask = mask
        
        let exists = existedBorder != nil
        if !exists {
            layer.addSublayer(border)
        }
    }
    
    func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }
    
    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         layer.mask = mask
     }
     
     @IBInspectable var borderColor: UIColor {
             get {
                 guard let cgColor = layer.borderColor else {
                     return .black
                 }
                 return UIColor(cgColor: cgColor)
             }
             set { layer.borderColor = newValue.cgColor }
         }

         @IBInspectable var borderWidth: CGFloat {
             get {
                 return layer.borderWidth
             }
             set {
                 layer.borderWidth = newValue
             }
         }
     
     func applyGradient(colours: [UIColor]) -> CAGradientLayer {
            return self.applyGradient(colours: colours, locations: nil)
        }


        func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = colours.map { $0.cgColor }
            gradient.locations = locations
            self.layer.insertSublayer(gradient, at: 0)
            return gradient
        }
     
     @IBInspectable var shadow: Bool {
           get {
               return layer.shadowOpacity > 0.0
           }
           set {
               if newValue == true {
                   self.addShadow()
               }
           }
       }

       @IBInspectable var cornerRadius: CGFloat {
           get {
               return self.layer.cornerRadius
           }
           set {
               if !circled{
                   self.layer.cornerRadius = newValue
               }

               // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
               if shadow == false {
                   self.layer.masksToBounds = true
               }
           }
       }
    @IBInspectable var circled: Bool {
        get {
            return self.layer.cornerRadius == self.frame.width / 2
        }
        set {
            if newValue{
                self.layer.cornerRadius = self.frame.width / 2;
                self.layer.borderWidth = self.borderWidth
                self.layer.borderColor = self.borderColor.cgColor
                self.clipsToBounds = true
            }
        }
    }


       func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                  shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                  shadowOpacity: Float = 0.4,
                  shadowRadius: CGFloat = 3.0) {
           layer.shadowColor = shadowColor
           layer.shadowOffset = shadowOffset
           layer.shadowOpacity = shadowOpacity
           layer.shadowRadius = shadowRadius
       }
}

//extension UIColor {
//    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
//        return UIGraphicsImageRenderer(size: size).image { rendererContext in
//            self.setFill()
//            rendererContext.fill(CGRect(origin: .zero, size: size))
//        }
//    }
//}
