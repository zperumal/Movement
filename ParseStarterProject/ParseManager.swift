//
//  ParseHelper.swift
//  Movement
//
//  Created by Zara Perumal on 12/28/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import Parse
import RateLimit

class ParseManager : NSObject
{
    let healthkitManager = HealthKitManager()
    var objectsParsed = 0
    // parse object 
    func parseHKObject ( hko : HealthKitManager.healthRecord)
    
    {
     print(String(hko))
    }
    func parseRecords (records : [HealthKitManager.healthRecord]){
       let ra = HealthKitManager.healthRecord.jsonArray(records)
       //print(ra)
        let data : NSData = ra.dataUsingEncoding( NSUTF8StringEncoding)!
        
        let objectToSave = PFObject(className:"toBeSaved")
        objectToSave["ObjectsToBeSaved"] = PFFile(data:data)
        objectToSave.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("toBeSavedObject saved")
            } else {
                // There was a problem, check error.description
                print(error?.description)
            }
        }

    }
  
   
}
