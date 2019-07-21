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
    
    //MARK: IBOUTLET
    
    
    //MARK: IBACTION

    
    @IBAction func showPlayer(_ sender: UIBarButtonItem) {
        let player = storyboard?.instantiateViewController(identifier: "player") as! ViewController
        player.mode = "show"
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
            navigationController?.pushViewController(listing, animated: true)
            
        }else if item["type"] == "File"{
            
            if Session.shared.upNextList.count == 0 && Session.shared.nowPlaying == "" {
                let player = storyboard?.instantiateViewController(identifier: "player") as! ViewController
                player.mode = "play"
                player.filename = currentPath + "\(item["name"]!)"
                player.path = currentPath
                Session.shared.nowPlaying = item["name"]!
                Session.shared.upNextList.removeAll()
                Session.shared.upNextItem.removeAll()
                for i in self.listing{
                    var url = baseURL + self.currentPath + i["name"]!
                    url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    Session.shared.upNextItem.append(AVPlayerItem(url: URL(string: url)!))
                    Session.shared.upNextList.append(i["name"]!)
                }
                Session.shared.mp = AVQueuePlayer(items: Session.shared.upNextItem)
                navigationController?.pushViewController(player, animated: true)
            }else{
                let options = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                options.addAction(UIAlertAction(title: "Add to Up Next", style: .default, handler: { (_) in
                    Session.shared.upNextList.append(item["name"]!)
                    
                    var url = baseURL + self.currentPath + item["name"]!
                    url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    
                    Session.shared.upNextItem.append(AVPlayerItem(url: URL(string: url)!))
                    Session.shared.mp.insert(AVPlayerItem(url: URL(string: url)!), after: Session.shared.mp.items().last)
                    
                    let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }))
                options.addAction(UIAlertAction(title: "Repeat Album", style: .default, handler: { (_) in
                    Session.shared.upNextList.removeAll()
                    Session.shared.upNextItem.removeAll()
                    for i in self.listing{
                        var url = baseURL + self.currentPath + i["name"]!
                        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        Session.shared.upNextItem.append(AVPlayerItem(url: URL(string: url)!))
                        Session.shared.upNextList.append(i["name"]!)
                    }
                    Session.shared.mp = AVQueuePlayer(items: Session.shared.upNextItem)
                    let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }))
                options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(options, animated: true, completion: nil)
            }
            
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
                self.title = self.currentPath
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
