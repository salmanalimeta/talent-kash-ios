//
//  VersionModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 13/12/2022.
//

import Foundation

struct VersionModel : Codable {
    let resultCount : Int?
    let results : [Results]?
}

struct Results : Codable {
    
    let version : String?
  
}
