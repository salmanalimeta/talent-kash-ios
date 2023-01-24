//
//  OrderModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 10/10/2022.
//

import Foundation

struct OrderModel:Codable {
    
    let status: Bool
    let message: String
    let click2Pay: String?
    let payProStatus : String?
    let payProId : String?
    let orderDate,order_datetime : String?
    let order_id : String?
    
  
}


