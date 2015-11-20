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

class Question2ViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var PushSteps: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
   var questions = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        self.tableView.registerClass(QuestionTableViewCell.self, forCellReuseIdentifier: "questionCell")
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
 
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell :QuestionTableViewCell  = QuestionTableViewCell()
        
       let cell : QuestionTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("questionCell", forIndexPath: indexPath) as! QuestionTableViewCell
        
        cell.questionLabel = UILabel()
        cell.answerView = UIView()
        cell.questionLabel.text = "hello world"
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func getNamesAndScores(){
        let max_count = 5
        var query : String = "getNextQuestions"
        PFCloud.callFunctionInBackground(query, withParameters: [:]) { (result: AnyObject?, error: NSError?) in
            let quests = result as? NSArray
            self.questions = []
            if quests != nil{
                for s in quests! {
                    if max_count <= 0 {
                        break
                    }
                    let q = s as! NSDictionary
                    let openEnded :Bool = q["openEnded"] as! Bool
                    
                    
                }
                self.tableView.reloadData()
            }
        }
        
    }

}