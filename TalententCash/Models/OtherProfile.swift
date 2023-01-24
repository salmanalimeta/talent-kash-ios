//
//  OtherProfile.swift
//  Talent Cash
//
//  Created by Aamir on 19/10/2022.
//

import Foundation


struct OtherReel:Decodable {
    let _id: String
    let hashtag: [String]
    let mentionPeople: [String]
    let isProductShow: Bool
    let like, comment: Int
    let isDelete: Bool
    let service_price, initial_price, remaining_price: Int
    let service: String?
    let isService: Bool
    let categoryId: Int
    let lat, long: String
    let userId: String
    let video: String
    let song: String?
    let caption: String?
    let thumbnail, screenshot, productImage: String?
    let productURL, productTag: String?
    let date: String
    let availabileTime: String?
    let createdAt, updatedAt: String
    let __v: Int
    let speed: String
    let allowComment: Bool?
    let duration: Int?
    let isOriginalAudio: Bool?
    let showVideo: Int?
    let size: String?
    let view: Int?
}
