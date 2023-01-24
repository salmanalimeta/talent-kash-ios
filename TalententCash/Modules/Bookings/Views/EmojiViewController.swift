//
//  EmojiViewController.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 30/09/2022.
//

import UIKit

class EmojiViewController: StatusBarController {

    
    var rating: Int!
    var onBackToHome:()->Void = {}
    @IBOutlet weak var emoji: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emoji.image = UIImage(named: rating > 2 ? rating > 3 ? "VeryHappyEmoji" : "HappyEmoji" : "SabEmoji")
    }
    
    @IBAction func homeAct(_ sender: Any) {
        dismiss(animated: false) {
            self.onBackToHome()
        }
        
    }
    

}
