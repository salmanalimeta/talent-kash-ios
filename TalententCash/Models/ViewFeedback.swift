//
//  ViewFeedback.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 30/09/2022.
//

import UIKit
import Foundation

// MARK: - SubmitFeedbackModel
struct ViewFeedback: Codable {
    let status: Bool
    let message: String
    let checkFeedback: CheckFeedback
}

// MARK: - CheckFeedback
struct CheckFeedback: Codable {
    let id, reelID, bookingID: String
    let rating: Int
    let checkFeedbackDescription, feedbackDate: String
    let isDelete: Bool
    let userID, talentUserID, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case reelID = "reelId"
        case bookingID = "bookingId"
        case rating
        case checkFeedbackDescription = "description"
        case feedbackDate = "feedback_date"
        case isDelete
        case userID = "userId"
        case talentUserID = "talentUserId"
        case createdAt, updatedAt
    }
}

