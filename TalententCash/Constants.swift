//
//  Constants.swift
//  ColorWidget
//
//  Created by Rao Mudassar on 28/07/2021.
//

import Foundation
import UIKit
import CoreData
import GSPlayer

struct Constants {
    
    static var baseUrl = "https://talentcash.pk/"
    static var videoArray:[Reel] = []
    //    static var userVideoArray:[ProfileReel] = []
    static var servicesArray:[servicelist] = []
    static var videoUserName = ""
    static var videoImage = ""
    static var videoName = ""
    static var notSenderID = ""
    static var notReceiverID = ""
    static var notSenderName = ""
    
    struct URL {
        static let service = baseUrl+"service/getServices"
        static let login = baseUrl+"user"
        static let logout = baseUrl+"user/logout"
        static let postVideo = baseUrl+"reels/upload"
        static let songs = baseUrl+"song"
        static let lginWithPhone = baseUrl+"user/loginWithNumber"
        static let userSignup = baseUrl+"user/userSignup"
        static let generateOTP = baseUrl+"user/generateOTP"
        static let checkSocialUserExists = baseUrl+"user/checkSocialUserExists"
        static let comments = baseUrl+"comment"
        static let like = baseUrl+"like"
        static let userGift = baseUrl+"gift/userGift"
        
        static let userProfile = baseUrl+"user/profile"
        static let editProfile = baseUrl+"user/update"
        static let userWiseReelAndroid = baseUrl+"reels/userWiseReelAndroid"
        
        static let activities = baseUrl+"notification?"
        //        static let service = baseUrl+"service"
        
        //MARK: Reels endpoints
        static let reels = baseUrl+"reels"
        static let reelsData = baseUrl+"reels/getreel/?"
        static let reportReel = baseUrl+"reels/banReel"
        static let getSpecificReel = baseUrl+"reels/getSpecificReel?reelId="
        
        static let checkAvailability = baseUrl+"booking/checkAvailability?talentUserId="
        static let sendRequest = baseUrl+"notification/sendOfferNotificationToTalentProvider"
        static let sendStatusToUser = baseUrl+"notification/acceptRejectOfferNotificationToUser"
        static let activeList = baseUrl+"booking/activeBookingListUser?userId="
        static let completeList = baseUrl+"booking/completedBookingListUser?userId="
        static let invoice = baseUrl+"payment/userCompleteBookingInvoice?bookingId="
        static let submitFeedback = baseUrl+"feedback/submitFeedback"
        static let viewFeedback = baseUrl+"feedback/viewFeedback"
        static let banUser = baseUrl+"block"
        static let follow = baseUrl+"follower"
        static let follower = baseUrl+"follower/followers"
        static let following = baseUrl+"follower/following"
        static let otherProfile = baseUrl+"user/otherProfile"
        static let checkNumberExist = baseUrl+"user/checkNumberExist"
        static let forgotPassword = baseUrl+"user/forgotPassword"
        
        //MARK: Wallet Module
        
        static let sendChatNotification = baseUrl+"chat/sendChatNotification"
        
        //MARK: Wallet Module
        static let walletCoins = baseUrl+"coinPlan"
        static let createOrder = baseUrl+"orderCoin/createOrder"
        static let walletHistory = baseUrl+"orderCoin/coinsHistroy?userId="
        static let walletHistoryDetail = baseUrl+"orderCoin/coinRechargeDetail?userId="
        static let jazzCashSecureHashForIOS = baseUrl+"orderCoin/jazzCashSecureHashForIOS"
        
        //MARK: Booking Provider Module
        static let activeTalentList = baseUrl+"booking/activeBookingListTalent/?talentUserId="
        static let completedBookingListTalent = baseUrl+"booking/completedBookingListTalent/?talentUserId="
        static let talentProviderTotalEarning = baseUrl+"payment/talentProviderTotalEarning?talentUserId="
        static let completeTalentProviderOrder = baseUrl+"booking/completeTalentProviderOrder/?bookingId="
        //        static let trackTalentProviderOrderSummary = baseUrl+"booking/trackTalentProviderOrderSummary/?bookingId=6332e5ccdd23710dc1f51b4c" // this record does not needed its already fetched by order list api
        static let talentCompleteBookingInvoice = baseUrl+"payment/talentCompleteBookingInvoice/?bookingId="
        
        static let userSearch = baseUrl+"user/userSearch"
        static func getReels(page:Int,limit:String,userId:String,categoryId:String,userSpecificReels:Bool)->String{
            reels+"/\(userSpecificReels ? "userWiseReelAndroid": "getreel")/?start=\(page)&limit=\(limit)\(userId.isEmpty ? "" : "&userId=\(userId)")&categoryId=\(categoryId)"
        }
        static func reels(start:String,limit:String)->String{
            baseUrl+"reels?start=\(start)&limit=\(limit)&startDate=ALL&endDate=ALL%27"
        }
        static func hashTags(type:String = "",start:Int? = nil,limit:String = "" ,userId:String)->String{
            baseUrl+"hashtag/hashtag?type=\(type)\(start == nil ? "" : "&start=\(start.unsafelyUnwrapped)&limit=\(limit)&userId=\(userId)")"
        }
        static func notifications(type:String = "")->String{
            baseUrl+"notification?userId=\(UserDefaultManager.instance.userID)&type=\(type)"
        }
    }
    
    static func getFormattedDate(string: String , formatter:String,formatter1:String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatter
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = formatter1
        
        let date: Date? = dateFormatterGet.date(from:string)
        //print("Date",dateFormatterPrint.string(from: date!)) // Feb 01,2018
        if(date == nil){
            
            return "nil"
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let currentDate = Date()
            let nowDate = formatter.string(from: currentDate)
            let firstDate = formatter.date(from: nowDate)
            let secondDate = formatter.date(from: string)
            
            if firstDate?.compare(secondDate!) == .orderedSame {
                
                return "Today"
            }else{
                
                return dateFormatterPrint.string(from: date!)
            }
        }
        
    }
    
    static let filterList = [
        CFilter(name: "CIColorControls", displayName: "Normal"),
        CFilter(name: "CIPhotoEffectChrome", displayName: "Chrome"),
        CFilter(name: "CIPhotoEffectFade", displayName: "Fade"),
        CFilter(name: "CIPhotoEffectInstant", displayName: "Instant"),
        CFilter(name: "CIPhotoEffectMono", displayName: "Mono"),
        CFilter(name: "CIPhotoEffectNoir", displayName: "Noir"),
        CFilter(name: "CIPhotoEffectProcess", displayName: "Process"),
        CFilter(name: "CIPhotoEffectTonal", displayName: "Tonal"),
        CFilter(name: "CIPhotoEffectTransfer", displayName: "Transfer"),
        CFilter(name: "CILinearToSRGBToneCurve", displayName: "Tone"),
        CFilter(name: "CIColorClamp", displayName: "Linear"),
        CFilter(name: "CIColorMatrix", displayName: "Clamp"),
        CFilter(name: "CIColorPolynomial", displayName: "Matrix"),
        CFilter(name: "CIExposureAdjust", displayName: "Exposure"),
        CFilter(name: "CIGammaAdjust", displayName: "Gamma"),
        CFilter(name: "CIHueAdjust", displayName: "Polynomial"),
        CFilter(name: "CISRGBToneCurveToLinear", displayName: "SRGBTone"),
        CFilter(name: "CIToneCurve", displayName: "Temperature"),
        CFilter(name: "CIVibrance", displayName: "Vibrance"),
        CFilter(name: "CIWhitePointAdjust", displayName: "WhitePoint"),
        CFilter(name: "CIBoxBlur", displayName: "BoxBlur"),
        CFilter(name: "CIMotionBlur", displayName: "Motion Blur"),
        CFilter(name: "CIGaussianBlur", displayName: "GaussianBlur"),
        CFilter(name: "CIZoomBlur", displayName: "Zoom Blur"),
        CFilter(name: "CIBumpDistortion", displayName: "BulgeDistortion"),
        CFilter(name: "CIColorCubeWithColorSpace", displayName: "CGAColorspace"),
        CFilter(name: "CIColorControls", displayName: "Contrast",inputs: ["inputContrast":1.5]),
        CFilter(name: "CIColorControls", displayName: "Brightness",inputs: ["inputBrightness":0.4]),
        CFilter(name: "CIHatchedScreen", displayName: "Crosshatch"),
        CFilter(name: "CIPhotoEffectNoir", displayName: "GrayScale"),
        CFilter(name: "CICMYKHalftone", displayName: "Halftone"),
        CFilter(name: "CITemperatureAndTint", displayName: "Haze"),
        CFilter(name: "CIHighlightShadowAdjust", displayName: "HighlightShadow"),
        CFilter(name: "CIHueAdjust", displayName: "Hue"),
        CFilter(name: "CIColorInvert", displayName: "Invert"),
        CFilter(name: "CIColorMatrix", displayName: "LookUpTable", inputs: ["inputRVector":CIVector(x: 0.5, y: 0, z: 0),"inputGVector":CIVector(x: 0, y: 0.5, z: 0),"inputBVector":CIVector(x: 0, y: 0, z: 0.9)]),
        CFilter(name: "CIColorMonochrome", displayName: "Monochrome"),
        CFilter(name: "CIColorMatrix", displayName: "Opacity", inputs: ["inputAVector":CIVector(x: 0, y: 0, z: 0, w: 0.6)]),
        CFilter(name: "CIBoxBlur", displayName: "Bilateral Blur"),
        CFilter(name: "CIPixellate", displayName: "Pixelation"),
        CFilter(name: "CIColorPosterize", displayName: "Posterize"),
        CFilter(name: "CIColorControls", displayName: "Saturation",inputs: ["inputSaturation":20]),
        CFilter(name: "CISepiaTone", displayName: "Sepia"),
        CFilter(name: "CISharpenLuminance", displayName: "Sharp",inputs: ["inputSharpness":1]),
        CFilter(name: "CISharpenLuminance", displayName: "Extra Sharp",inputs: ["inputSharpness":3]),
        CFilter(name: "CIColorControls", displayName: "Luminance",inputs: ["inputSaturation":0.0]),
        CFilter(name: "CIPhotoEffectNoir", displayName: "Noir Effect"),
        CFilter(name: "CITemperatureAndTint", displayName: "Temperature",inputs: ["inputNeutral":CIVector(x: 6500, y: 700),"inputTargetNeutral":CIVector(x: 6500, y: 0)]),
        CFilter(name: "CIBumpDistortion", displayName: "Bump Distortion"),
        CFilter(name: "CITwirlDistortion", displayName: "Swirl"),
        CFilter(name: "CIVibrance", displayName: "Vibrance",inputs: ["inputAmount":20]),
        CFilter(name: "CIVignette", displayName: "Vignette",inputs: ["inputIntensity":10])
    ]
    
}

