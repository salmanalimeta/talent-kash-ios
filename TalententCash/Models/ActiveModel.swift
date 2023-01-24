//
//  ActiveModel.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 28/09/2022.
//

import UIKit

    struct ActiveModel: Codable {
        let status: Bool
        let message: String
        let activeBookingList: [ActiveBookingList]
        let totalUser: Int
    }

    // MARK: - ActiveBookingList
    struct ActiveBookingList: Codable {
        let id, reelID, time, service: String
        let price, initialPrice, remainingPrice, status: Int
        let activeBookingListDescription, acceptDate,booking_id, completedDate: String?
        let isFeedbackAdd, isDelete: Bool
        let talentUserID: TalentUserID?
        let userID, createdAt, updatedAt: String

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case booking_id = "booking_id"
            case reelID = "reelId"
            case time, service, price
            case initialPrice = "initial_price"
            case remainingPrice = "remaining_price"
            case status
            case activeBookingListDescription = "description"
            case acceptDate = "accept_date"
            case completedDate = "completed_date"
            case isFeedbackAdd, isDelete
            case talentUserID = "talentUserId"
            case userID = "userId"
            case createdAt, updatedAt
        }
    }

    // MARK: - TalentUserID
    struct TalentUserID: Codable {
        let ad: Ad
        let gender: String?
        let id, name, username, analyticDate: String
        let bio: String
        let followers, following, like, view: Int
        let comment, reels, diamond, requestForWithdrawDiamond: Int
        let coin: Int
        let profileImage: String
        let coverImage: String?
        let isBlock, isOnline: Bool
        let loginType: Int
        let socialID: String?
        let notification: Bool
        let userRole: String
        let userPhone: Int
        //let gift: [String]?
        let identity, email, fcmToken, lastLogin: String?

        enum CodingKeys: String, CodingKey {
            case ad, gender
            case id = "_id"
            case name, username, analyticDate, bio, followers, following, like, view, comment, reels, diamond, requestForWithdrawDiamond, coin, profileImage, coverImage, isBlock, isOnline, loginType
            case socialID = "social_id"
            case notification
            case userRole = "user_role"
            case userPhone = "user_phone"
            case identity, email
            case fcmToken = "fcm_token"
            case lastLogin
        }
    }

