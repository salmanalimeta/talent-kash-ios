//
//  reelCommentModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 20/09/2022.
//

import UIKit

    class reelCommentModel: Codable {
        let status: Bool
        let message: String
        let comment: [comment]?
    }

    // MARK: - User
    class comment: Codable {
        let _id, userId, screenshot, image: String?
        let name: String?
        let username: String?
        let comment, time: String?
    }
