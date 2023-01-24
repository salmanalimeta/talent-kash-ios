//
//  Inbox.swift
//  Talent Cash
//
//  Created by MacBook Pro on 26/09/2022.
//

import UIKit

class Inbox: NSObject {
  
    var receiverId:String = ""
    var receiverName:String = ""
    var message:String = ""
    var date:String = ""
   
    init(receiverId: String, receiverName: String, message: String, date: String) {
    
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.message = message
        self.date = date
     
    }

}

