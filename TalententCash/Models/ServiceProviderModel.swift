//
//  ServiceModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 05/10/2022.
//

import Foundation

struct ServiceProviderModel:Codable {
    let status: Bool
    let message: String
    let service: [servicelist]
}

struct servicelist:Codable {
    
    let service_name:String?
    let service_id:Int
    
}
