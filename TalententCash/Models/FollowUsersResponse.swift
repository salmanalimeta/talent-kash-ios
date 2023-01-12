//
//  FollowUsers.swift
//  Talent Cash
//
//  Created by MacBook Pro on 25/10/2022.
//

import Foundation

struct FollowUsersResponse:Decodable{
    let status:Bool
    let message:String
    let user:[FollowUser]
}
struct FollowUser:Decodable{
    let userId:String
    let name:String
    let username:String
    let image:String
    let bio:String
    var isFollow:Bool
}
