//
//  Session.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/21.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import AVKit

class Session: NSObject{
    
    static let shared = Session()
    
    var mp = AVQueuePlayer()
    
    var nowPlaying = ""
    var nowArtwork: UIImage?
    
    var upNextList = [String]()
    
    var upNextItem = [AVPlayerItem]()
    
}
