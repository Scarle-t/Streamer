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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var enlarged = false
    var playerNames = [String]()
    
    @IBOutlet weak var nowPlaying: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var st: UILabel!
    @IBOutlet weak var et: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var coverBg: UIImageView!
    @IBOutlet weak var upNextBtn: UIButton!
    @IBOutlet weak var upNextList: UITableView!
    
    @IBAction func playPause(_ sender: UIButton) {
        if Session.shared.mp.rate == 0.0{
            Session.shared.mp.play()
        }else if Session.shared.mp.rate == 1.0{
            Session.shared.mp.pause()
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func enlargeCover(_ sender: UITapGestureRecognizer) {
        if enlarged{
            UIView.animate(withDuration: 0.2) {
                self.albumCover.frame = CGRect(x: 57, y: 123, width: self.view.frame.width, height: 300)
                self.albumCover.center.x = self.view.center.x
            }
            enlarged = false
        }else{
            UIView.animate(withDuration: 0.2) {
                self.albumCover.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            }
            if upNextBtn.tag == 1{
                showUpNext(upNextBtn)
            }
            enlarged = true
        }
    }
    
    @IBAction func showUpNext(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            setup()
            UIView.animate(withDuration: 0.2) {
                self.upNextList.frame.origin.y = self.playPauseBtn.frame.origin.y + 45
            }
            sender.tag = 1
        case 1:
            UIView.animate(withDuration: 0.2) {
                self.upNextList.frame.origin.y = self.view.frame.height
            }
            sender.tag = 0
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = playerNames[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            Session.shared.mp.remove(Session.shared.mp.items()[indexPath.row + 1])
            Session.shared.playerItems.remove(at: indexPath.row + 1)
            Session.shared.playerNames.remove(at: indexPath.row + 1)
            setup()
        }
    }
    
    func setup(){
        playerNames.removeAll()
        for i in Session.shared.counter ..< Session.shared.playerNames.count{
            playerNames.append(Session.shared.playerNames[i])
        }
        if playerNames.count == 1 && playerNames[0] == Session.shared.currentSong{
            playerNames.removeAll()
        }
        upNextList.reloadData()
    }
    
    func delegate(){
        upNextList.delegate = self
        upNextList.dataSource = self
    }
    
    func layout(){
        albumCover.center.x = view.center.x
        upNextList.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - playPauseBtn.frame.origin.y - 45)
        upNextList.frame.origin.y = view.frame.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        delegate()
        
        layout()
        
        let mp = Session.shared.mp
        
        mp.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (t) in
            guard let item = mp.currentItem else {return}
            let duration = CMTimeGetSeconds((item.asset.duration))
            let time = CMTimeGetSeconds((item.currentTime()))
            
            self.et.text = String(format: "%02d:%02d", Int(duration / 60), Int(duration) % 60)
            self.st.text = String(format: "%02d:%02d", Int(time / 60), Int(time) % 60)
            self.nowPlaying.text = Session.shared.currentSong
            self.albumCover.image = Session.shared.currentCover
            self.coverBg.image = Session.shared.currentCover
            self.progress.progress = Float(time / duration)
            if mp.rate == 1.0 {
                self.playPauseBtn.setImage(UIImage(systemName: "pause"), for: .normal)
            }else if mp.rate == 0.0{
                self.playPauseBtn.setImage(UIImage(systemName: "play"), for: .normal)
            }
        }
        
        setup()
        
    }

}

