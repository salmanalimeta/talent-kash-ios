//
//  ActiveBookingListTalent.swift
//  Talent Cash
//
//  Created by MacBook Pro on 30/09/2022.
//

import Foundation


// MARK: - Welcome
struct ActiveBookingTalentRespond:Codable {
    let status: Bool
    let message: String
    let activeBookingList: [ActiveBooking]
    let totalUser: Int
}

// MARK: - ActiveBookingList
struct ActiveBooking:Codable {
    let _id, reelId, time, service: String
    let price, initial_price, remaining_price, status: Int
    let activeBookingListDescription,booking_id: String?
    let accept_date: String
    let completed_date: String?
    let isFeedbackAdd, isDelete: Bool
    let talentUserId: String
    let userId: UserID?
    let createdAt, updatedAt: String
}

// MARK: - UserID
struct UserID:Codable {
    let ad: Ad
    let _id, name, username, analyticDate: String
    let gender: String?
    let bio: String
    let followers, following, like, view: Int
    let comment, reels, diamond, requestForWithdrawDiamond: Int
    let coin: Int
    let profileImage: String
    let coverImage: String?
    let isBlock, isOnline: Bool
    let loginType: Int
    let social_id: String?
    let notification: Bool
    let user_role: String
    let user_phone: Int
   // let gift: [String]?
    let identity, email, fcm_token, lastLogin: String?
}


