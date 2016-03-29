//
//  HomeViewController.swift
//  Movement
//
//  Created by Zara Perumal on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Locksmith

class HomeViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var PushSteps: UISegmentedControl!
    let service = "swiftLogin"
    let userAccount = "swiftLoginUser"
    @IBOutlet weak var sendData: UIButton!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var kerberos: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmpassword: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var question :Question?
    let healthkitManager = HealthKitManager()
    let parseManager = ParseManager()
    var namesandscores :[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        getNamesAndScores()
        getQuestions( {error in
            if error != nil{
                print(error)
            }
        })
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        setPostLabel()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let date = PFUser.currentUser()!.valueForKey("syncedTo") {
            let syncdate = date as! NSDate
            
            let calendar: NSCalendar = NSCalendar.currentCalendar()            //if NSDate().timeIntervalSinceDate(syncdate) <= 12 * 60 * 60 {
            if( calendar.compareDate(NSDate(), toDate: syncdate, toUnitGranularity: NSCalendarUnit.Day) != .OrderedDescending ){
                sendData.enabled = false
            }else{
                sendData.enabled = true
            }
        }
        
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func sync(){
        sendData.enabled = false
        syncData()
        
        //self.backgroundThread(0.0, background: {
          //  self.manageQuestionPopup()})
            manageQuestionPopup()
            //questionPopup()
    }
    func syncData(){
        healthkitManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
                self.syncBackgroundThread(0.0, background: {
                    self.healthkitManager.fillRecords() { error in
                        if error != nil {
                            print("\(error)")
                        }else {
                            let records = self.healthkitManager.getRecords()
                            self.parseManager.parseRecords(records)
                            print(records.count)
                            
                            PFUser.currentUser()?.setValue(NSDate(), forKey: "sycnedTo")
                           // self.syncCompleted()
                            
                            
                        }
                    }
                    
                })
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
        
        
        PFUser.currentUser()!.incrementKey("posts" )
        PFUser.currentUser()?.saveInBackground()
        setPostLabel()
        getNamesAndScores()
    }
    
    func setPostLabel(){
        
        if let posts = PFUser.currentUser()!.valueForKey("posts") {
        print(String(posts))
        postLabel.text = String(posts)
        }
        
        getNamesAndScores()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logout" {
            do{
                try   Locksmith.deleteDataForUserAccount(self.userAccount , inService: service)
            }
            catch   {
               print("can't  log out")
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesandscores.count
        //return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.backgroundView?.backgroundColor = UIColor.clearColor()
        cell.backgroundView?.alpha = 0.8
        
        cell.textLabel?.text = namesandscores[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func getNamesAndScores(){
        let max_count = 5
        var query : String
        var scoreField : String
        if PushSteps.selectedSegmentIndex == 0 {
            query = "getLeaderboard"
            scoreField = "posts"
            
        } else{
            query = "getStepLeaderboard"
            scoreField = "weeklySteps"
        }
        PFCloud.callFunctionInBackground(query, withParameters: [:]) { (result: AnyObject?, error: NSError?) in
            let scores = result as? NSArray
            self.namesandscores = []
            if scores != nil {
            for s in scores! {
                if max_count <= 0 {
                    break
                }
                let score = s as! NSDictionary
                var name :String = String(score["username"]!)
                name = name.stringByPaddingToLength(15, withString: " ", startingAtIndex: 0)
                if let post = score[scoreField] {
                    self.namesandscores += [name + "\t\t\t\t" + String(post)]
                }else{
                    
                    self.namesandscores += [name]
                }
                
            }
          self.tableView.reloadData()
        }
        }
      
    }
    
    func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }
    func syncBackgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
        if let date = PFUser.currentUser()!.valueForKey("syncedTo") {
            let syncdate = date as! NSDate
            
            let calendar: NSCalendar = NSCalendar.currentCalendar()            //if NSDate().timeIntervalSinceDate(syncdate) <= 12 * 60 * 60 {
            if( calendar.compareDate(NSDate(), toDate: syncdate, toUnitGranularity: NSCalendarUnit.Day) != .OrderedDescending ){
                self.sendData.enabled = false
            }else{
                self.sendData.enabled = true
            }
        }
        
    }
    
    @IBAction func segmentedControllerChanged(sender: AnyObject) {
        getNamesAndScores()
    }
    func syncCompleted (){
        let alertController = UIAlertController(title: "Sync completed", message:
            "Thanks!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion:  {
            
        })

    }
    func getQuestions(completion: ( NSError?) -> ()){
        let query  = PFQuery(className:"Question")
        query.whereKey("active", equalTo: true)
        query.whereKey("pushQuestion", equalTo: true)
        var lastQuestion =  PFUser.currentUser()!.valueForKey("lastQuestion")
        if lastQuestion == nil {
            lastQuestion = 0
        }
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    let object = objects[0]
                        
                        let questionObj  = object.objectForKey("Question")
                        if questionObj != nil {
                            let question = questionObj as! String
                            var answerKeys = ["AnswerA","AnswerB","AnswerC","AnswerD","AnswerE"]
                            var answers : [String] = []
                            
                            for a in answerKeys {
                                //var answer = object[a] as! String
                                var answerobj  = object.objectForKey(a)
                                if answerobj != nil {
                                    var answer : String = answerobj as! String
                                    if answer != "" {
                                        answers += [answer]
                                    }
                                }
                                
                            }
                            self.question =  Question(questionText : question, buttons: answers)
                        }
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    func manageQuestionPopup(){
        if question != nil {
           showQuestionPopup()
        }else{
            getQuestions( { error in
                if error != nil {
                    print("\(error)")
                }
                else{
                    self.showQuestionPopup()
                }
                
            })
        }
    }
    func showQuestionPopup(){
        var alert = UIAlertController(title: (question?.questionText)!, message: "", preferredStyle: .Alert)
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        for answer in (question?.buttons)!{
            var buttonAction = UIAlertAction(title: answer, style: UIAlertActionStyle.Default) {
                UIAlertAction in
                var response = PFObject(className:"Response")
                response["questionText"] = (self.question?.questionText)!
                response["responseText"] = answer
                response["user"] = PFUser.currentUser()
                 response.saveInBackgroundWithBlock   {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("Object Saved")
                        } else {
                            print("ERROR: save error")
                        }
                }
            }
            alert.addAction(buttonAction)
        }
        if question?.buttons.count == 0 {
            alert.addTextFieldWithConfigurationHandler(nil)
            
            let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, alert] (action: UIAlertAction!) in
                let answer = alert.textFields![0].text!
                var response = PFObject(className:"Response")
                response["questionText"] = (self.question?.questionText)!
                response["responseText"] = answer
                response["user"] = PFUser.currentUser()
                print(response["user"])
                response.saveInBackgroundWithBlock   {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("Object Saved")
                    } else {
                        print("ERROR: save error")
                    }
                }
            }
            alert.addAction(submitAction)
        }
        alert.addAction(cancelAction)
       presentViewController(alert, animated: true, completion: nil)
    }

}