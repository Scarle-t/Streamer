//
//  ViewController.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/21.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class ViewController: UIViewController {
    
    var mp: AVQueuePlayer?
    var mpi : AVPlayerItem?
    var nowPlayingInfo = [String : Any]()
    var mode = ""
    var filename: String?
    var path: String?
    var itemName: [AVPlayerItem : String]?
    
    @IBOutlet weak var nowPlaying: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var st: UILabel!
    @IBOutlet weak var et: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var repeatBtn: UIButton!
    
    @IBAction func playPause(_ sender: UIButton) {
        if mp?.rate == 0.0{
            mp?.play()
        }else if mp?.rate == 1.0{
            mp?.pause()
        }
    }
    
    fileprivate func setupCC() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.mp = Session.shared.mp
            if self.mp?.rate == 0.0 {
                self.mp?.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.mp = Session.shared.mp
            if self.mp?.rate == 1.0 {
                self.mp?.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        
        if let p = path?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            Network().get(url: baseURL + p + "folder.jpg", method: "GET", query: nil) { (data) in
                guard let d = data else {return}
                
                if let cover = UIImage(data: d){
                    DispatchQueue.main.async {
                        self.albumCover.image = cover
                        Session.shared.nowArtwork = cover
                        self.nowPlayingInfo[MPMediaItemPropertyArtwork] =
                            MPMediaItemArtwork(boundsSize: cover.size) { size in
                                return cover
                        }
                    }
                }
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = mp?.rate
        nowPlayingInfo[MPMediaItemPropertyTitle] = Session.shared.nowPlaying
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mp = Session.shared.mp
        
        if mode == "play"{
            Session.shared.mp.pause()
        }
        
        setupCC()
        setupNowPlayingInfo()
        
        mp?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (t) in
            guard let item = self.mp?.currentItem else {return}
            
            Session.shared.nowPlaying = String((self.itemName?[item]?.split(separator: ".").first)!)
            
            self.nowPlaying.text = Session.shared.nowPlaying
            
            let duration : Float64 = CMTimeGetSeconds((item.asset.duration))
            let time = CMTimeGetSeconds((item.currentTime()))
            
            self.et.text = String(format: "%02d:%02d", Int(duration / 60), Int(duration) % 60)
            
            self.st.text = String(format: "%02d:%02d", Int(time / 60), Int(time) % 60)
            
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
            self.nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            self.nowPlayingInfo[MPMediaItemPropertyTitle] = Session.shared.nowPlaying
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
            
            self.progress.progress = Float(time / duration)
            
        }
        
        Session.shared.mp.play()
        
    }


}

