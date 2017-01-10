//
//  BingAPI.swift
//  BingWallpaper
//
//  Created by John Stray on 2/1/17.
//  Copyright © 2017 John Stray. All rights reserved.
//

import Foundation

class BingAPI {
    
    var RESOLUTION = "1920x1200"
    var baseurl: [String] = []
    var SAVE_PATH = "/Volumes/MacOS/Users/johnstray/Pictures/"
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            
            let results = regex.matches(in: text,
                                        options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
            
        } catch let error as NSError {
            
            print("invalid regex: \(error.localizedDescription)")
            
            return []
        }
    }
    
    
    
    func fetchWallpaperDetails() -> NSArray {
        let url = URL(string: "https://www.bing.com/HPImageArchive.aspx?format=js&n=1")
        var returnData = [String]()
        
        do {
            let allData = try Data(contentsOf: url!)
            let allItems = try JSONSerialization.jsonObject(with: allData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
            if let arrJSON = allItems["images"] {
                for index in 0...arrJSON.count-1 {
                    let aObject = arrJSON[index] as! [String : AnyObject]
                    
                    let jsonCopyrightString = aObject["copyright"] as! String
                    let jsonUrlBase = aObject["url"] as! String
                    let jsonEndDate = aObject["enddate"] as! String
                    let jsonCWLink = aObject["copyrightlink"] as! String
                    
                    /* Calculate the copyright string */
                    let regex = "\\((.*?)\\)"
                    let cwMatchedString = matchesForRegexInText(regex: regex, text: jsonCopyrightString)[0]
                    let cwIndexStart = cwMatchedString.index(cwMatchedString.startIndex, offsetBy: 1)
                    let cwIndexEnd = cwMatchedString.index(cwMatchedString.endIndex, offsetBy: -2)
                    let cwSubString = cwMatchedString.substring(from: cwIndexStart)
                    let cwString = cwSubString.substring(to: cwIndexEnd)
                    
                    /* Calculate the Image Title */
                    let cwLength = cwMatchedString.characters.count + 1
                    let itIndex = jsonCopyrightString.index(jsonCopyrightString.endIndex, offsetBy: -cwLength)
                    let itString = jsonCopyrightString.substring(to: itIndex)
                    
                    /* Prepend bing url to baseurl */
                    let ubString = "https://www.bing.com" + jsonUrlBase
                    
                    /* Calculate Date String */
                    let pdFormatter = DateFormatter()
                    pdFormatter.dateFormat = "yyyyMMdd"
                    let pdDateObject = pdFormatter.date(from: jsonEndDate)
                    pdFormatter.dateFormat = "dd MMMM, yyyy"
                    let pdString = pdFormatter.string(from: pdDateObject!)
                    
                    /* Return all that data */
                    returnData.append(itString)
                    returnData.append(cwString)
                    returnData.append(ubString)
                    returnData.append(pdString)
                    returnData.append(jsonCWLink)
                    
                }
            }
            
        } catch {
            
        }
        
        return returnData as NSArray
    }
    
}

