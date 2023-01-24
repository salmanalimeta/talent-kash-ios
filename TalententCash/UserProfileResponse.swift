//
//  profileModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 21/09/2022.
//

import UIKit

class UserProfileResponse: Codable {

    let status: Bool
    let message: String
    let user: User
}

//class UserProfile: Codable {
//    let ad: Ad?
//    let gender: String?
//    let _id, name, username, analyticDate: String?
//    let bio: String?
//    let reels, following, like, view: Int?
//    var followers:Int = 0
//    let comment, diamond, requestForWithdrawDiamond: Int?
//    let coin: Int?
//    let profileImage: String?
//    let coverImage: String?
//    var isBlock,isFollow:Bool?
//    let isOnline: Bool?
//    let loginType: Int?
//    let notification,is_number_verify: Bool?
//    let userRole: String?
//    //let gift: [String]?
//    let identity, email, lastLogin: String?
//}

struct ProfileReel:Codable {
    let _id: String
    let hashtag, mentionPeople: [String]
    let isProductShow, isOriginalAudio: Bool?
    var like, comment : Int
    let allowComment: Bool?
    let showVideo, duration: Int?
    let speed,size: String?
    let isDelete: Bool
    let servicePrice, initialPrice, remainingPrice: Int?
    let service: String?
    let isService: Bool
    let categoryId:Int?
    let userID: String?
    let video: String?
    let song: String?
    let lat:String?
    let long:String?
    let location, caption, thumbnail, screenshot: String?
    let productImage, productURL: String?
    let productTag, date, availabileTime, createdAt: String?
    let updatedAt: String?
    let __v: Int
    let view: Int?
    let user: User?
    let analyticDate: String?
}
