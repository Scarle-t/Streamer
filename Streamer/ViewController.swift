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
    
    var mp = AVPlayer()
    var mpi : AVPlayerItem?
    var nowPlayingInfo = [String : Any]()
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var st: UILabel!
    @IBOutlet weak var et: UILabel!
    @IBOutlet weak var mt: UILabel!
    
    @IBAction func playPause(_ sender: UIButton) {
        if mp.rate == 0.0{
            mp.play()
        }else if mp.rate == 1.0{
            mp.pause()
        }
    }
    
    fileprivate func setupSession(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func setupCC() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
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
    
    fileprivate func setupNowPlayingInfo() {
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = mpi?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = mpi?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = mp.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let url = "https://scarletsc.net/Song/test/test.flac"
        mpi = AVPlayerItem(url: URL(string: url)!)
        mp = AVPlayer(playerItem: mpi)
        
        setupSession()
        setupCC()
        setupNowPlayingInfo()
        
        let seconds : Float64 = CMTimeGetSeconds((mpi?.asset.duration)!)
        let myTimes = String(Int(seconds / 60)) + ":" + String(Int(seconds) % 60)
        et.text = myTimes
        
        mp.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (t) in
            let time = CMTimeGetSeconds(self.mp.currentTime())
            
            let myTimes2 = String(Int(time / 60)) + ":" + String(Int(time) % 60)
            self.st.text = myTimes2
            
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.mpi?.currentTime().seconds
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
            
            self.progress.progress = Float(time / seconds)
            
        }
        
        mp.play()
        
    }


}

