//
//  CoinsModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 07/10/2022.
//

import Foundation

struct CoinsModel: Codable {
    
    let status: Bool
    let message: String
    let coinPlan: [coins]
}

struct coins: Codable {
    
    let _id, tag,productKey,createdAt,updatedAt: String?
    let coin,rupee,dollar: Int?

}
