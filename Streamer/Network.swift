//
//  Network.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/21.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import UIKit

class Network: NSObject{
    
//    weak var delegate: NetworkDelegate?
    
    func get(url action: String, method: String, query content: String?, completion: ((Data?)->())?){
        
        if Reachability().isConnectedToNetwork(){
            var request = URLRequest(url: URL(string: action)!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = method
            if let content = content{
                request.httpBody = content.data(using: .utf8)
            }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("URL Error")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // check for http errors
                    print("HTTP Error")
                    return
                }
                completion?(data)
            }
            task.resume()
        }else{
            print("Network Error")
        }
    }
    
}
