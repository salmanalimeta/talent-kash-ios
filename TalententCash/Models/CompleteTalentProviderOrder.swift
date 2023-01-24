//
//  completeTalentProviderOrder.swift
//  Talent Cash
//
//  Created by MacBook Pro on 03/10/2022.
//

import Foundation

struct CompleteTalentProviderOrderResponse:Decodable {
    let status:Bool
    let message:String
    let booking:Booking
}

struct Booking:Decodable {
    let _id, reelId, time, service: String
    let price, initial_price, remaining_price, status: Int
    let description: String?
    let accept_date, completed_date: String?
    let isFeedbackAdd, isDelete: Bool
    let talentUserId, userId, createdAt, updatedAt: String
}
