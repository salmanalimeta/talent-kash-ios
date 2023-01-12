//
//  Conversation.swift
//  Talent Cash
//
//  Created by MacBook Pro on 24/09/2022.
//

import UIKit

class Conversation: NSObject {
    
    var senderId:String = ""
    var receiverId:String = ""
    var senderName:String = ""
    var message:String = ""
    var date:String = ""
    var time:String = ""
    var type:String = ""
    var image:String = ""
    var profileImage:String = ""
    var chatId:String = ""
    
    init(senderId: String, receiverId: String, senderName: String, message: String, date: String, time: String, type: String, image: String, profileImage: String, chatId: String) {
        self.senderId = senderId
        self.receiverId = receiverId
        self.senderName = senderName
        self.message = message
        self.date = date
        self.time = time
        self.type = type
        self.image = image
        self.profileImage = profileImage
        self.chatId = chatId
    }
}
