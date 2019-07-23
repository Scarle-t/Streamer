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
    
    @IBOutlet weak var nowPlaying: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var st: UILabel!
    @IBOutlet weak var et: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var playPauseBtn: UIButton!
    
    @IBAction func playPause(_ sender: UIButton) {
        if Session.shared.mp.rate == 0.0{
            Session.shared.mp.play()
        }else if Session.shared.mp.rate == 1.0{
            Session.shared.mp.pause()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let mp = Session.shared.mp
        
        mp.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (t) in
            guard let item = mp.currentItem else {return}
            let duration = CMTimeGetSeconds((item.asset.duration))
            let time = CMTimeGetSeconds((item.currentTime()))
            
            self.et.text = String(format: "%02d:%02d", Int(duration / 60), Int(duration) % 60)
            self.st.text = String(format: "%02d:%02d", Int(time / 60), Int(time) % 60)
            self.nowPlaying.text = Session.shared.currentSong
            self.albumCover.image = Session.shared.currentCover
            self.progress.progress = Float(time / duration)
            if mp.rate == 1.0 {
                self.playPauseBtn.setImage(UIImage(systemName: "pause"), for: .normal)
            }else if mp.rate == 0.0{
                self.playPauseBtn.setImage(UIImage(systemName: "play"), for: .normal)
            }
        }
        
    }


}

