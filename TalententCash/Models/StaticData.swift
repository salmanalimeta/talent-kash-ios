//
//  StaticData.swift
//  Talent_Cash_App
//
//  Created by Aamir on 07/09/2022.
//

import Foundation

class StaticData{
    
   static let obj = StaticData()
    
    init() {
        
        print("abc")
    }
   
    var userName:String! = ""
    var userImg:String! = ""
    var soundName:String! = ""
    var like_count:String! = "0"
    var comment_count:String! = "0"
    var liked:String! = "0"
    var videoID:String! = "0"
    var other_id:String! = ""
    var receiver_id:String! = ""
    var receiver_name:String! = ""
    var receiver_img:String! = ""
    
    var liveUserID = ""
    var liveUserName = ""
    
    var BundleIdentifer = ""
}
