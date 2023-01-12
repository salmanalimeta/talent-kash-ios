//
//  OTPModel.swift
//  Talent Cash
//
//  Created by MacBook Pro on 19/09/2022.
//

import UIKit


class OTPModel: Codable {
    let status: Bool
    let message: String
    let otp: Int?
}
