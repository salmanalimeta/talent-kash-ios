//
//  ActivitiesModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 22/09/2022.
//

import UIKit

class ActivitiesModel: Codable {

    let status: Bool
    let message: String
    let notifications: [Notifications]?
}

class Notifications: Codable {

    let _id,userId, name, message, otherUserId,reelId: String?
    let image: String?
    let date: String?
    let time: String?
    
}
