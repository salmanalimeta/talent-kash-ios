//
//  talentCompleteBookingInvoice.swift
//  Talent Cash
//
//  Created by MacBook Pro on 30/09/2022.
//

import Foundation
import SwiftUI

// MARK: - Welcome
struct TalentCompleteBookingInvoiceResponse:Codable {
    let status: Bool
    let message: String
    let talentCompleteBookingInvoice: [TalentCompleteBookingInvoice]
}

// MARK: - TalentCompleteBookingInvoice
struct TalentCompleteBookingInvoice:Codable {
    let _id,invoice_id, reelId: String
    let bookingId: BookingID
    let amount: Int
    let pay_datetime: String
    let payment_type, payment_method: Int
    let transaction_Id: String?
    let payment_status: Int
    let isDelete: Bool
    let talentUserId: TalentUserID1
    let userId: UserID1
    let createdAt, updatedAt: String
}
struct UserID1:Codable{
    let _id:String
    let user_id:String?
    let name:String
    let username:String
    let gender:String?
}
struct BookingID:Codable {
    let _id,booking_id, reelId, time, service: String
    let price: Int
    let accept_date: String
}
