//
//  Session.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/21.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class Session: NSObject{
    
    static let shared = Session()
    
    var mp = AVQueuePlayer()
    
    var nowPlayingInfo = [String : Any]()
    
    var playerItems = [[AVPlayerItem : ItemInfo]]()
    var playerNames = [String]()
    var currentSong = ""
    var currentCover = UIImage()
    
    var duration = Float64()
    var time = Float64()
    
    var counter = 0
    
    func play(){
        mp.pause()
        mp.removeAllItems()
        playerNames.removeAll()
        counter = 0
        for item in playerItems{
            for (k, v) in item{
                mp.insert(k, after: mp.items().last)
                playerNames.append(v.name)
            }
        }
        setupCC()
        mp.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (t) in
            guard let item = self.mp.currentItem, let info = self.playerItems[self.counter][item] else {return}
            
            self.time = CMTimeGetSeconds((item.currentTime()))
            
            if info.name != self.currentSong{
                self.currentSong = info.name
                
                self.duration = CMTimeGetSeconds((item.asset.duration))
                self.nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.duration
                self.nowPlayingInfo[MPMediaItemPropertyTitle] = self.currentSong
                if let path = info.artwork.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                    Network().get(url: baseURL + path, method: "GET", query: nil) { (data) in
                        guard let d = data, let cover = UIImage(data: d) else {return}
                        self.currentCover = cover
                        self.nowPlayingInfo[MPMediaItemPropertyArtwork] =
                            MPMediaItemArtwork(boundsSize: cover.size) { size in
                                return cover
                        }
                    }
                }
                self.counter += 1
                if self.counter == self.playerItems.count{
                    self.counter -= 1
                }
            }
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.time
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
        }
        mp.play()
    }
    
    fileprivate func setupCC() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = nil
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = nil
        nowPlayingInfo[MPMediaItemPropertyTitle] = nil
        nowPlayingInfo[MPMediaItemPropertyArtwork] = nil
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.mp.rate == 0.0 {
                self.mp.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.mp.rate == 1.0 {
                self.mp.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
}
