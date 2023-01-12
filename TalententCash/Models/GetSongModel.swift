//
//  GetSongModel.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 13/09/2022.
//

import UIKit
import Foundation

class GetSongModel: Codable {
    
        let status: Bool
        let message: String
        let song: [SongModel]

        init(status: Bool, message: String, song: [SongModel]) {
            self.status = status
            self.message = message
            self.song = song
        }
    }

    // MARK: - Song
    class SongModel: Codable {
        let id: String
        let isDelete: Bool
        let title, singer, image, song: String
        var selectedSong = false
        let createdAt, updatedAt: String

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case isDelete, title, singer, image, song, createdAt, updatedAt
        }
//        init(id: String, isDelete: Bool, title: String, singer: String, image: String, song: String, createdAt: String, updatedAt: String) {
//            self.id = id
//            self.isDelete = isDelete
//            self.title = title
//            self.singer = singer
//            self.image = image
//            self.song = song
//            self.createdAt = createdAt
//            self.updatedAt = updatedAt
//        }
    }
