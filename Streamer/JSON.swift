//
//  JSON.swift
//  Streamer
//
//  Created by Scarlet on A2019/J/21.
//  Copyright © 2019 Scarlet. All rights reserved.
//

import Foundation

class JSON: NSObject{
    fileprivate var jsonResult = NSArray()
    fileprivate var jsonElement = NSDictionary()
    fileprivate var returnDict = [NSDictionary]()
    
    func parse(_ data: Data) -> [NSDictionary]?{
        returnDict.removeAll()
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch {
            print("JSON Error")
            return nil
        }
        
        for i in 0 ..< jsonResult.count
        {
            jsonElement = jsonResult[i] as! NSDictionary
            returnDict.append(jsonElement)
        }
        return returnDict
    }
}
