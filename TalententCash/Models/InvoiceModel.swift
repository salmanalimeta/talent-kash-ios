

import Foundation

// MARK: - InvoiceModel
struct InvoiceModel: Codable {
    let status: Bool
    let message: String
    let userCompleteBookingInvoice: [UserCompleteBookingInvoice]
}

// MARK: - UserCompleteBookingInvoice
struct UserCompleteBookingInvoice: Codable {
    let _id, reelId,invoice_id: String
    let bookingId: BookingID
    let amount: Int
    let pay_datetime: String
    let payment_type, payment_method: Int
    let transaction_id: String?
    let payment_status: Int
    let isDelete: Bool
    let talentUserId: TalentUserID1
    let createdAt, updatedAt: String
    let userId:UserID1
}

// MARK: - TalentUserID
struct TalentUserID1: Codable {
    let gender: String?
    let _id,user_id, name, username: String?
}
