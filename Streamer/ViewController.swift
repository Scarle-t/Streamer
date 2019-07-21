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
            if self.mp?.rate == 0.0 {
                self.mp?.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.mp?.rate == 1.0 {
                self.mp?.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        if mode == "show"{
            DispatchQueue.main.async {
                self.albumCover.image = Session.shared.nowArtwork
                self.nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: Session.shared.nowArtwork!.size) { size in
                        return Session.shared.nowArtwork!
                }
            }
        }else{
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
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = mpi?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = mpi?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = mp?.rate
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = Session.shared.nowPlaying
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc func didFinishPlaying(){
        if Session.shared.upNextList.count != 0{
            DispatchQueue.main.async {
                self.nowPlaying.text = Session.shared.upNextList[0]
                Session.shared.nowPlaying = Session.shared.upNextList[0]
                self.nowPlayingInfo[MPMediaItemPropertyTitle] = Session.shared.nowPlaying.split(separator: ".")[0]
            }
        }else{
            DispatchQueue.main.async {
                self.nowPlaying.text = ""
                Session.shared.nowPlaying = ""
                self.nowPlayingInfo[MPMediaItemPropertyTitle] = .none
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mp = Session.shared.mp
        nowPlaying.text = Session.shared.nowPlaying
        
        if mode == "show"{
            setupCC()
            setupNowPlayingInfo()
            guard let item = mp?.currentItem else {return}
            
            mp?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (t) in
                let seconds : Float64 = CMTimeGetSeconds((item.asset.duration))
                let myTimes = String(Int(seconds / 60)) + ":" + String(Int(seconds) % 60)
                self.et.text = myTimes
                
                let time = CMTimeGetSeconds((self.mp?.currentItem?.currentTime())!)
                
                let myTimes2 = String(Int(time / 60)) + ":" + String(Int(time) % 60)
                self.st.text = myTimes2
                
                self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.mp?.currentTime().seconds
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
                
                self.progress.progress = Float(time / seconds)
                
                if seconds == time {
                    if Session.shared.upNextList.count != 0{
                        Session.shared.upNextList.remove(at: 0)
                        if Session.shared.upNextList.count != 0{
                            self.nowPlaying.text = Session.shared.upNextList[0]
                            self.nowPlayingInfo[MPMediaItemPropertyTitle] = Session.shared.nowPlaying.split(separator: ".")[0]
                        }
                    }else{
                        self.nowPlaying.text = ""
                        self.nowPlayingInfo[MPMediaItemPropertyTitle] = .none
                    }
                }
                
            }
        }else if mode == "play"{
            var url = baseURL + filename!
            url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            mpi = AVPlayerItem(url: URL(string: url)!)
            
            Session.shared.upNextItem.insert(mpi!, at: 0)
            if mp?.rate == 1.0{
                mp?.pause()
                mp = AVQueuePlayer(items: Session.shared.upNextItem)
            }else{
                Session.shared.mp = AVQueuePlayer(playerItem: mpi)
                mp = Session.shared.mp
            }
            setupCC()
            setupNowPlayingInfo()
            
            mp?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (t) in
                let seconds : Float64 = CMTimeGetSeconds((self.mp?.currentItem?.asset.duration)!)
                let myTimes = String(Int(seconds / 60)) + ":" + String(Int(seconds) % 60)
                self.et.text = myTimes
                
                let time = CMTimeGetSeconds((self.mp?.currentItem?.currentTime())!)
                
                let myTimes2 = String(Int(time / 60)) + ":" + String(Int(time) % 60)
                self.st.text = myTimes2
                
                self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.mp?.currentTime().seconds
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
                
                self.progress.progress = Float(time / seconds)
                
                if seconds == time {
                    if Session.shared.upNextList.count != 0{
                        Session.shared.upNextList.remove(at: 0)
                        if Session.shared.upNextList.count != 0{
                            self.nowPlaying.text = Session.shared.upNextList[0]
                            self.nowPlayingInfo[MPMediaItemPropertyTitle] = Session.shared.nowPlaying.split(separator: ".")[0]
                        }
                    }else{
                        self.nowPlaying.text = ""
                        self.nowPlayingInfo[MPMediaItemPropertyTitle] = .none
                    }
                    
                    
                }
                
            }
            Session.shared.upNextList.remove(at: 0)
            Session.shared.upNextItem.remove(at: 0)
            mp?.play()
        }
        
    }


}

