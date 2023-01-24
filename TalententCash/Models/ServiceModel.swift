import UIKit
import Combine

// MARK: - ContactDetails
class ServiceModel: Codable {
    let status: Bool
    let message: String
    let service: service?
}

// MARK: - User
class service: Codable {
    let ad: Ad?
    let gender: String?
    let _id, name, username, analyticDate: String?
    let bio: String?
    let followers,reel, following, like, view: Int?
    let comment, diamond, requestForWithdrawDiamond: Int?
    let coin: Int?
    let profileImage: String?
    let coverImage: String?
    let isBlock, isOnline: Bool?
    let loginType: Int?
    let notification,is_number_verify: Bool?
    let userRole: String?
    //let gift: [String]?
    let identity, email, lastLogin: String?
}
