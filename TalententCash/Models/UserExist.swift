//
//  UserExist.swift
//  Talent Cash
//
//  Created by MacBook Pro on 25/10/2022.
//

import Foundation

struct UserExist: Codable {
    let status: Bool
    let message: String
    let user: User?
}
