//
//  VideoViewController.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 15/09/2022.
//

import Foundation
import UIKit
import AVKit

class VideoVoiewController: AVPlayerViewController {
    
    var videoUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = .init(url: URL(string: videoUrl)!)
        player?.play()
                       
    }
    
    
    
    
    
}
