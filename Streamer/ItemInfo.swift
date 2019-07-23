//
//  PlayerItem.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/23.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import Foundation
import AVKit

class ItemInfo: NSObject{
    
    //MARK: ATTRIBUTE
    var name: String
    var album: String
    var artwork: String
    
    //MARK: INIT
    override init(){
        name = ""
        album = ""
        artwork = ""
    }
    
}
