//
//  UserSearchResponse.swift
//  Talent Cash
//
//  Created by MacBook Pro on 26/10/2022.
//

import Foundation

struct UserSearchResponse:Decodable{
    let status:Bool
    let message:String
    let search:[User]
}
