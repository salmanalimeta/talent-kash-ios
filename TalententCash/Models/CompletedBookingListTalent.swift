//
//  completedBookingListTalent.swift
//  Talent Cash
//
//  Created by MacBook Pro on 30/09/2022.
//

import Foundation

// MARK: - Welcome
struct CompletedBookingTalentResponse:Decodable {
    let status: Bool
    let message: String
    let completedBookingList: [CompletedBookingList]
    let totalUser: Int
}

// MARK: - CompletedBookingList
struct CompletedBookingList:Decodable {
    let _id, reelId, time, service: String
    let price, initial_price, remaining_price, status: Int
    let description: String?
    let accept_date, completed_date,booking_id: String?
    let isFeedbackAdd, isDelete: Bool
    let talentUserId: String
    let userId: UserID
    let createdAt, updatedAt: String
}

//struct UserID {
//    let ad: Ad
//    let id, name, username, analyticDate: String
//    let gender: NSNull
//    let bio: String
//    let followers, following, like, view: Int
//    let comment, reels, diamond, requestForWithdrawDiamond: Int
//    let coin: Int
//    let profileImage: String
//    let coverImage: NSNull
//    let isBlock, isOnline: Bool
//    let loginType: Int
//    let socialID: NSNull
//    let notification: Bool
//    let userRole: String
//    let userPhone: Int
//    let gift: [Any?]
//    let identity, email, fcmToken, lastLogin: String
//}


//struct Ad {
//    let count: Int
//    let date: NSNull
//}

