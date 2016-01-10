//
//  HealthKitManager.swift
//  Movement
//
//  Created by Zara Perumal on 12/28/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import HealthKit
import Parse
class HealthKitManager : NSObject
{
    let dateManager = DateManager()
    let queue = NSOperationQueue()
    var records = [healthRecord]()
    let storage = HKHealthStore()
    let beginningDate = NSDate(dateString:"2014-08-01")
    var remainingOps : Int64 = 0

    
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let readTypes = NSSet(objects: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)! , HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!)
        
      
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError( domain: "ZaraPerumal.movement.healthkit" , code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        storage.requestAuthorizationToShareTypes(nil, readTypes: readTypes as? Set<HKObjectType>){ (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    func getRecords() -> [healthRecord] {
        return records
    }

    func fillRecords(completion: ( NSError?) -> ()){
        func operationDone( _: NSError?) -> (){
            self.remainingOps = self.remainingOps - 1
        }
        let syncedTo  = PFUser.currentUser()!.valueForKey("syncedTo")
        let now = dateManager.getDateHourRoudnedDown(NSDate())
        var beginning : NSDate
        if syncedTo == nil {
            //beginning = NSDate(dateString:"2014-08-01")
            beginning = NSDate(dateString:"2014-08-01")
        }else{
            beginning = syncedTo as! NSDate
        }
        let hoursback = dateManager.hoursBack(now,past:  beginning)
        remainingOps = hoursback * 3
        for i in 0..<hoursback
        {
            //var op = NSBlockOperation( block: {
                //print("Healthkit hours:" + String(i))
                let startDate = self.dateManager.getDateRoundedPlusHours(now ,hours:  0 - i)
                let endDate = self.dateManager.getDateRoundedPlusHours(now, hours: 1-i)
                self.fillArray(startDate!, endDate: endDate!, recordType: RecordType.Step, completion : operationDone)
                self.fillArray(startDate!, endDate: endDate!, recordType: RecordType.Distance, completion : operationDone)
                self.fillArray(startDate!, endDate: endDate!, recordType: RecordType.Flight, completion : operationDone)
           // }
           //) queue.addOperation( op )
        }
        
        queue.suspended = false
        queue.waitUntilAllOperationsAreFinished()
        
        print("done!")
        completion(nil)
    }
    
    func fillArray(startDate : NSDate, endDate :NSDate, recordType : RecordType , completion: ( NSError?) -> ()){
        var type : HKQuantityType
        var className : String
        var unit : HKUnit?
        switch recordType {
        case RecordType.Step:
            type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
            className = "Step"
            unit = HKUnit.countUnit()
            break
        case RecordType.Distance:
            type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
            className = "Distance"
            unit = HKUnit.mileUnit()
            break
        case RecordType.Flight:
            type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!
            className = "Flight"
            unit = HKUnit.countUnit()
            break
        case RecordType.None:
            return
        default:
            return
        }
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate , endDate: endDate, options: .None)
        
        // The actual HealthKit Query which will fetch all of the steps and sum them up for us.
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var count: Double = 0
            
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    /*
                    
                    */
                    count += result.quantity.doubleValueForUnit(unit!)
                }
            }
            
            
            completion( error)
            if count > 0 {
                /*let record = PFObject(className:className)
                record["sampleType"] = className
                record["startDate"] = startDate
                record["endDate"] = endDate
                record["quantity"] = count
                record["User"] = PFUser.currentUser()
                */
                self.records += [healthRecord(sampleType: className, startDate: startDate, endDate: endDate, quantity: count, user:  PFUser.currentUser()!)]
            }
        }
        var op = NSBlockOperation( block: {
        self.storage.executeQuery(query)
        })
        queue.addOperation( op )
    }

    struct healthRecord {
        var sampleType = String();
        var startDate = NSDate();
        var endDate = NSDate();
        var quantity = Double();
        var user = PFUser();
        static func jsonArray(array : [healthRecord]) -> String
        {
            return "[" + array.map {$0.jsonRepresentation}.joinWithSeparator(",") + "]"
        }
        var jsonRepresentation : String {
            return "{\"sampleType\":\"\(sampleType)\",\"startDate\":\"\(startDate)\",\"endDate\":\"\(endDate)\",\"quantity\":\"\(quantity)\",\"user\":\"\(user)\"}"
        }
    
    }
    
}