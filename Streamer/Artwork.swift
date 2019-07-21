//
//  Artwork.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/21.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Artwork: UIViewController{
    
    //MARK: VARIABLE
    
    
    //MARK: IBOUTLET
    @IBOutlet weak var cover: UIImageView!
    
    
    //MARK: IBACTION
    
    
    //MARK: DELEGATION
    
    
    //MARK: OBJC FUNC
    
    
    //MARK: FUNC
    func delegate(){
        
    }
    
    func layout(){
        
    }
    
    func setup(){
        cover.image = Session.shared.nowArtwork
        title = String(Session.shared.nowPlaying.split(separator: ".")[0])
    }
    
    //MARK: VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
