//
//  Reels.swift
//  Talent_Cash_App
//
//  Created by Aamir on 12/09/2022.
//

import Foundation
// MARK: - Welcome
struct ReelResponse:Codable  {
    let status: Bool
    let message: String
    let reel: [Reel]
    //let totalReel: Int
}

// MARK: - Reel
struct Reel:Codable {
    let _id: String
    let hashtag, mentionPeople: [String]?
    let isProductShow, isOriginalAudio: Bool
    var like, comment : Int
    let allowComment: Bool
    let showVideo, duration: Int?
    let speed,size: String?
    let isDelete: Bool
    let service_price, initial_price, remaining_price: Int
    let service: String
    let isService: Bool
    let userID: String?
    let video: String?
    let song: Song?
    let location,lat,long, caption, thumbnail, screenshot: String?
    let productImage, productURL: String?
    let productTag, date, availabileTime, createdAt: String?
    let updatedAt: String?
    let view: Int
    var user: User
    let analyticDate: String
    var isLike:Bool
    
    enum CodingKeys: CodingKey {
        case _id
        case hashtag
        case mentionPeople
        case isProductShow
        case isOriginalAudio
        case like
        case comment
        case allowComment
        case showVideo
        case duration
        case speed
        case size
        case isDelete
        case service_price
        case initial_price
        case remaining_price
        case service
        case isService
        case userID
        case video
        case song
        case location
        case lat
        case long
        case caption
        case thumbnail
        case screenshot
        case productImage
        case productURL
        case productTag
        case date
        case availabileTime
        case createdAt
        case updatedAt
        case view
        case user
        case analyticDate
        case isLike
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(String.self, forKey: ._id)
        self.hashtag = try container.decodeIfPresent([String].self, forKey: .hashtag)
        self.mentionPeople = try container.decodeIfPresent([String].self, forKey: .mentionPeople)
        self.isProductShow = try container.decodeIfPresent(Bool.self, forKey: .isProductShow) ?? false
        self.isOriginalAudio = try container.decodeIfPresent(Bool.self, forKey: .isOriginalAudio) ?? true
        self.like = try container.decode(Int.self, forKey: .like)
        self.comment = try container.decode(Int.self, forKey: .comment)
        self.allowComment = try container.decodeIfPresent(Bool.self, forKey: .allowComment) ?? true
        self.showVideo = try container.decodeIfPresent(Int.self, forKey: .showVideo)
        self.duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        self.speed = try container.decodeIfPresent(String.self, forKey: .speed)
        self.size = try container.decodeIfPresent(String.self, forKey: .size)
        self.isDelete = try container.decode(Bool.self, forKey: .isDelete)
        self.service_price = try container.decodeIfPresent(Int.self, forKey: .service_price) ?? 0
        self.initial_price = try container.decodeIfPresent(Int.self, forKey: .initial_price) ?? 0
        self.remaining_price = try container.decodeIfPresent(Int.self, forKey: .remaining_price) ?? 0
        self.service = try container.decodeIfPresent(String.self, forKey: .service) ?? ""
        self.isService = try container.decode(Bool.self, forKey: .isService)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.video = try container.decodeIfPresent(String.self, forKey: .video)
        self.song = try container.decodeIfPresent(Song.self, forKey: .song)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.lat = try container.decodeIfPresent(String.self, forKey: .lat)
        self.long = try container.decodeIfPresent(String.self, forKey: .long)
        self.caption = try container.decodeIfPresent(String.self, forKey: .caption)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.screenshot = try container.decodeIfPresent(String.self, forKey: .screenshot)
        self.productImage = try container.decodeIfPresent(String.self, forKey: .productImage)
        self.productURL = try container.decodeIfPresent(String.self, forKey: .productURL)
        self.productTag = try container.decodeIfPresent(String.self, forKey: .productTag)
        self.date = try container.decodeIfPresent(String.self, forKey: .date)
        self.availabileTime = try container.decodeIfPresent(String.self, forKey: .availabileTime)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.view = try container.decodeIfPresent(Int.self, forKey: .view) ?? 0
        self.user = try container.decode(User.self, forKey: .user)
        self.analyticDate = try container.decodeIfPresent(String.self, forKey: .analyticDate) ?? ""
        self.isLike = try container.decode(Bool.self, forKey: .isLike)
    }
}



// MARK: - Song
struct Song:Codable {
    let _id: String
    let isDelete: Bool
    let title, singer, image, song: String
    let createdAt, updatedAt: String
    enum CodingKeys: CodingKey {
        case _id
        case isDelete
        case title
        case singer
        case image
        case song
        case createdAt
        case updatedAt
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        self.isDelete = try container.decodeIfPresent(Bool.self, forKey: .isDelete) ?? false
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.singer = try container.decodeIfPresent(String.self, forKey: .singer) ?? ""
        self.image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.song = try container.decodeIfPresent(String.self, forKey: .song) ?? "Original Song"
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
    }
}
// MARK: - User
struct User:Codable{
    var _id: String
    let ad: Ad
    let name, username, bio: String
    var followers, following, like, view: Int
    let diamond, requestForWithdrawDiamond: Int
    let comment, reels: Int
    let coin: Int
    let profileImage: String
    let coverImage: String
    var isBlock,isFollow:Bool
    let isOnline: Bool
    let loginType, user_phone: Int
    let notification,is_number_verify: Bool
    let analyticDate: String
    let identity, email, fcmToken, lastLogin: String
    let gender: String
    let user_role: String
    let jwtToken:String?
    
    
    enum CodingKeys: CodingKey {
        case _id
        case ad
        case name
        case username
        case bio
        case followers
        case following
        case like
        case view
        case diamond
        case requestForWithdrawDiamond
        case comment
        case reels
        case coin
        case profileImage
        case coverImage
        case isBlock
        case isFollow
        case isOnline
        case loginType
        case user_phone
        case notification
        case is_number_verify
        case analyticDate
        case identity
        case email
        case fcmToken
        case lastLogin
        case gender
        case user_role
        case jwtToken
    }
    init(id:String) {
        self._id = id
        self.ad =  .init(count: 0, date: "")
        self.name = ""
        self.username = ""
        self.bio = ""
        self.followers = 0
        self.following = 0
        self.like = 0
        self.view = 0
        self.diamond = 0
        self.requestForWithdrawDiamond = 0
        self.comment = 0
        self.reels = 0
        self.coin = 0
        self.profileImage = ""
        self.coverImage = ""
        self.isBlock = false
        self.isFollow = false
        self.isOnline = false
        self.loginType = 0
        self.user_phone = 0
        self.notification = false
        self.is_number_verify = false
        self.analyticDate = ""
        self.identity = ""
        self.email = ""
        self.fcmToken = ""
        self.lastLogin = ""
        self.gender = ""
        self.user_role = ""
        self.jwtToken = ""
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        self.ad = try container.decodeIfPresent(Ad.self, forKey: .ad) ?? .init(count: 0, date: "")
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        self.followers = try container.decodeIfPresent(Int.self, forKey: .followers) ?? 0
        self.following = try container.decodeIfPresent(Int.self, forKey: .following) ?? 0
        self.like = try container.decodeIfPresent(Int.self, forKey: .like) ?? 0
        self.view = try container.decodeIfPresent(Int.self, forKey: .view) ?? 0
        self.diamond = try container.decodeIfPresent(Int.self, forKey: .diamond) ?? 0
        self.requestForWithdrawDiamond = try container.decodeIfPresent(Int.self, forKey: .requestForWithdrawDiamond) ?? 0
        self.comment = try container.decodeIfPresent(Int.self, forKey: .comment) ?? 0
        self.reels = try container.decodeIfPresent(Int.self, forKey: .reels) ?? 0
        self.coin = try container.decodeIfPresent(Int.self, forKey: .coin) ?? 0
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
        self.coverImage = try container.decodeIfPresent(String.self, forKey: .coverImage) ?? ""
        self.isBlock = try container.decodeIfPresent(Bool.self, forKey: .isBlock) ?? false
        self.isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow) ?? false
        self.isOnline = try container.decodeIfPresent(Bool.self, forKey: .isOnline) ?? false
        self.loginType = try container.decodeIfPresent(Int.self, forKey: .loginType) ?? 0
        self.user_phone = try container.decodeIfPresent(Int.self, forKey: .user_phone) ?? 0
        self.notification = try container.decodeIfPresent(Bool.self, forKey: .notification) ?? false
        self.is_number_verify = try container.decodeIfPresent(Bool.self, forKey: .is_number_verify) ?? false
        self.user_role = try container.decodeIfPresent(String.self, forKey: .user_role) ?? ""
        self.analyticDate = try container.decodeIfPresent(String.self, forKey: .analyticDate) ?? ""
        self.identity = try container.decodeIfPresent(String.self, forKey: .identity) ?? ""
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.fcmToken = try container.decodeIfPresent(String.self, forKey: .fcmToken) ?? ""
        self.lastLogin = try container.decodeIfPresent(String.self, forKey: .lastLogin) ?? ""
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? ""
        self.jwtToken = try container.decodeIfPresent(String.self, forKey: .jwtToken) ?? ""
    }
}

// MARK: - Ad
struct Ad:Codable {
    let count: Int?
    let date: String?
}
