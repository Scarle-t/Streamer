//
//  UpNext.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/21.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class UpNext: UITableViewController{
    
    //MARK: VARIABLE
    var playerNames = [String]()
    
    //MARK: IBOUTLET
    
    
    //MARK: IBACTION
    
    
    //MARK: DELEGATION
        //MARK: TABLE VIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = playerNames[indexPath.row]
        return cell
    }
    
    
    //MARK: OBJC FUNC
    
    
    //MARK: FUNC
    func delegate(){
        
    }
    
    func layout(){
        
    }
    
    func setup(){
        playerNames.removeAll()
        for i in Session.shared.counter ..< Session.shared.playerNames.count{
            playerNames.append(Session.shared.playerNames[i])
        }
        tableView.reloadData()
    }
    
    //MARK: VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
