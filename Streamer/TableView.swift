//
//  TableView.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/21.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit
import AVKit

class TableView: UITableViewController{
    
    //MARK: VARIABLE
    let network = Network()
    var listing = [[String : String]]()
    var currentPath = ""
    var albumName = ""
    
    //MARK: IBOUTLET
    
    
    //MARK: IBACTION

    
    @IBAction func showPlayer(_ sender: UIBarButtonItem) {
        let player = storyboard?.instantiateViewController(identifier: "player") as! ViewController
        navigationController?.pushViewController(player, animated: true)
    }
    
    //MARK: DELEGATION
        //MARK: TABLE VIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listing.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let item = listing[indexPath.row]
        
        cell.textLabel?.text = item["name"]
        
        if item["type"] == "Folder"{
            cell.accessoryType = .disclosureIndicator
        }else if item["type"] == "File"{
            cell.accessoryType = .none
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        let item = listing[indexPath.row]
        
        if item["type"] == "Folder"{
            let listing = storyboard?.instantiateViewController(identifier: "listing") as! TableView
            listing.currentPath = currentPath + item["name"]! + "/"
            listing.albumName = item["name"]!
            navigationController?.pushViewController(listing, animated: true)
            
        }else if item["type"] == "File"{
            Session.shared.playerItems.removeAll()
            
            if indexPath.row != 0 {
                for l in indexPath.row ..< listing.count{
                    if listing[l]["type"] == "File"{
                        var url = baseURL + currentPath + listing[l]["name"]!
                        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let AVItem = AVPlayerItem(url: URL(string: url)!)
                        let itemInfo = ItemInfo()
                        itemInfo.name = String(listing[l]["name"]!.split(separator: ".").first!)
                        itemInfo.album = albumName
                        itemInfo.artwork = currentPath + "folder.jpg"
                        
                        Session.shared.playerItems.append([AVItem : itemInfo])
                    }
                }
                for l in 0 ..< indexPath.row{
                    if listing[l]["type"] == "File"{
                        var url = baseURL + currentPath + listing[l]["name"]!
                        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let AVItem = AVPlayerItem(url: URL(string: url)!)
                        let itemInfo = ItemInfo()
                        itemInfo.name = String(listing[l]["name"]!.split(separator: ".").first!)
                        itemInfo.album = albumName
                        itemInfo.artwork = currentPath + "folder.jpg"
                        
                        Session.shared.playerItems.append([AVItem : itemInfo])
                    }
                }
            }else{
                for l in listing{
                    if l["type"] == "File"{
                        var url = baseURL + currentPath + l["name"]!
                        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let AVItem = AVPlayerItem(url: URL(string: url)!)
                        let itemInfo = ItemInfo()
                        itemInfo.name = String(l["name"]!.split(separator: ".").first!)
                        itemInfo.album = albumName
                        itemInfo.artwork = currentPath + "folder.jpg"
                        
                        Session.shared.playerItems.append([AVItem : itemInfo])
                    }
                }
            }
            
            
            Session.shared.play()
            let player = storyboard?.instantiateViewController(identifier: "player") as! ViewController
            navigationController?.pushViewController(player, animated: true)
        }
        
    }
    
    //MARK: OBJC FUNC
    
    
    //MARK: FUNC
    func get(path: String = ""){
        listing.removeAll()
        network.get(url: baseURL + "iOS.php?dir=" + path, method: "GET", query: nil) { (data) in
            guard let d = data, let result = JSON().parse(d) else {return}
            
            for item in result{
                var i = [String : String]()
                i.removeAll()
                i["name"] = item["name"] as? String
                i["type"] = item["type"] as? String
                self.listing.append(i)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.title = self.albumName
            }
        }
    }
    
    func delegate(){
        
    }
    
    func layout(){
        
    }
    
    func setup(){
        get(path: currentPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
    
    //MARK: VIEW CONTROLLER
    override func viewDidLoad(){
        super.viewDidLoad()
        
        delegate()
        
        layout()
        
        setup()
        
    }
    
}
