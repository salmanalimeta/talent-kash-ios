//
//  HashTag.swift
//  Talent Cash
//
//  Created by MacBook Pro on 21/09/2022.
//

import Foundation

struct HashTagResponse:Codable {
    let status: Bool
    let message: String
    let hashtag: [Hashtag]
}

struct Hashtag:Codable {
    let _id, hashtag: String
    let coverImage, hashtagDescription, image: String
    var reel: [Reel]
    let videoCount, likes, comments: Int
    enum CodingKeys: CodingKey {
        case _id
        case hashtag
        case coverImage
        case hashtagDescription
        case image
        case reel
        case videoCount
        case likes
        case comments
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        self.hashtag = try container.decodeIfPresent(String.self, forKey: .hashtag) ?? "NO TAG"
        self.coverImage = try container.decodeIfPresent(String.self, forKey: .coverImage) ?? ""
        self.hashtagDescription = try container.decodeIfPresent(String.self, forKey: .hashtagDescription) ?? ""
        self.image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.reel = try container.decodeIfPresent([Reel].self, forKey: .reel) ?? []
        self.videoCount = try container.decodeIfPresent(Int.self, forKey: .videoCount) ?? 0
        self.likes = try container.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        self.comments = try container.decodeIfPresent(Int.self, forKey: .comments) ?? 0
    }
    init() {
        self.reel = []
        self._id = ""
        self.image = ""
        self.comments = 0
        self.coverImage = ""
        self.hashtag = ""
        self.hashtagDescription = ""
        self.videoCount = 0
        self.likes = 0
    }
}

//struct HashReel:Codable {
//    let _id: String
//    let hashtag, mentionPeople: [String]
//    let isProductShow, isOriginalAudio: Bool?
//    var like, comment : Int
//    let allowComment: Bool?
//    let showVideo, duration: Int?
//    let speed,size: String?
//    let isDelete: Bool
//    let servicePrice, initialPrice, remainingPrice: Int?
//    let service: String?
//    let isService: Bool
//    let userID: String?
//    let video: String?
//    let song: Song?
//    let location, caption, thumbnail, screenshot: String?
//    let productImage, productURL: String?
//    let productTag, date, availabileTime, createdAt: String?
//    let updatedAt: String?
//    let __v: Int
//    let view: Int?
//    let user: User?
//    let analyticDate: String?
//}


