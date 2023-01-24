//
//  AppAnalytics.swift
//  Talent Cash
//
//  Created by Aamir on 13/12/2022.
//

import Foundation
import FirebaseAnalytics
import FBSDKCoreKit

class AppAnalytic{
    static let shared:AppAnalytic = AppAnalytic()
    enum Events: String {
        case LoginButton = "loginButton_iOS"
        case SignUpButton = "signUpButton_iOS"
        case VideoPost = "postButton_iOS"
    }
    
    func postAnalyticsEvent(event:Events) {
        Analytics.logEvent(event.rawValue, parameters: nil)
    }
    
    func postAnalyticsEventOnFB(event:Events) {
        AppEvents.logEvent(AppEvents.Name(rawValue: event.rawValue) , parameters: nil)
        AppEvents.logEvent(AppEvents.Name(rawValue: event.rawValue))
    }
}
