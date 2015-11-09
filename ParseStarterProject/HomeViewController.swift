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
    var namesandscores :[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        getNamesAndScores()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        setPostLabel()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func sync(){
        sendData.enabled = false
        syncData()
    }
    func syncData(){
        let hk = HealthKit()
        if hk.checkAuthorization(){
            backgroundThread(0.0, background: {
                hk.syncAll() { error in
                    //hk.lastDaysSteps() { error in
                    //  print(error)
                    self.sendData.enabled = true
                }
                
            })
        
        }
        PFUser.currentUser()!.incrementKey("posts" )
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
                let name :String = String(score["username"]!)
                if let post = score[scoreField] {
                    self.namesandscores += [name + "     " + String(post)]
                }else{
                    
                    self.namesandscores += [name ]
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
    
    @IBAction func segmentedControllerChanged(sender: AnyObject) {
        getNamesAndScores()
    }

}