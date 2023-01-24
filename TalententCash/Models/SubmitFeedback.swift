//
//  SubmitFeedback.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 30/09/2022.
//

import Foundation

struct SubmitFeedback: Codable {
    let status: Bool
    let message: String
    let insertRec: InsertRec
}
struct InsertRec: Codable {
    let reelId: String
    let bookingId: String
    let rating: Int
    let description: String
    let feedback_date: String
    let isDelete: Bool
    let _id: String
    let userId: String
    let talentUserId: String
    let createdAt: String
    let updatedAt: String
    
}
