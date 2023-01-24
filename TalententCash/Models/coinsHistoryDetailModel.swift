//
//  coinsHistoryDetailModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 11/10/2022.
//

import Foundation

struct coinsHistoryDetailModel: Codable {
    
    let status: Bool?
    let message: String?
    let coinDetails:coinDetails?

}

struct coinDetails: Codable {
    
    let _id,order_id,order_date,order_datetime: String?
    let coins,amount: Int?
 

}
