//
//  HealthManager.swift
//  Movement
//
//  Created by Zara Perumal on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//
import Foundation
import HealthKit
import Parse
class HealthKit
{
    let storage = HKHealthStore()
    
    init()
    {
        checkAuthorization()
    }
    
    func checkAuthorization() -> Bool
    {
        // Default to assuming that we're authorized
        var isEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable()
        {
            // We have to request each data type explicitly
            let steps = NSSet(object: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
            
            // Now we can request authorization for step count data
            storage.requestAuthorizationToShareTypes(nil, readTypes: steps as? Set<HKObjectType>) { (success, error) -> Void in
                isEnabled = success
            }
        }
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func lastDaysSteps(completion: ( NSError?) -> () )
    {
        // The type of data we are requesting (this is redundant and could probably be an enumeration
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // Our search predicate which will fetch data from now until a day ago
        // (Note, 1.day comes from an extension
        // You'll want to change that to your own NSDate
        let predicate = HKQuery.predicateForSamplesWithStartDate(NSDate().dateByAddingTimeInterval(-24 * 60 * 60) , endDate: NSDate(), options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
           // var steps: Double = 0
            
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    let stepRecord = PFObject(className:"Step")
                    stepRecord["sampleType"] = "Step"
                    stepRecord["startDate"] = result.startDate
                    stepRecord["endDate"] = result.endDate
                    stepRecord["quantity"] = result.quantity.doubleValueForUnit(HKUnit.countUnit())
                    stepRecord["User"] = PFUser.currentUser()
                    stepRecord.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("Step Record saved")
                        } else {
                            // There was a problem, check error.description
                            //print(error?.description)
                        }
                    }
                   // steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
            }
            
            completion( error)
        }
        
        storage.executeQuery(query)
    }
}