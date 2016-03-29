//
//  QuestionViewController.swift
//  Movement
//
//  Created by Zara Perumal on 11/11/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TextFieldQuestionTableViewCell : UITableViewCell, UITextViewDelegate {
    var placeholder = "Enter answer here"
    @IBOutlet var  questionLabel : UILabel!
    @IBOutlet var  answerField : UITextView!
    @IBOutlet var  submitButton : UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    func loadItem( question: String, cell : Int) {
     questionLabel.text = question
        questionLabel.lineBreakMode =  NSLineBreakMode.ByWordWrapping
        questionLabel.numberOfLines = 2
        questionLabel.sizeToFit()
        submitButton.tag = 99 + (100 * cell)
        skipButton.tag = 99 + (100 * cell)
        //self.reloadInputViews()
        answerField.delegate = self
        answerField.text = placeholder
        answerField.textColor = UIColor.lightGrayColor()
    }
    @IBAction func submit(){
        
    }
    
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        answerField.textColor = UIColor.blackColor()
        if answerField.text == placeholder {
            answerField.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(answerField.text == "") {
            self.answerField.text = placeholder
            self.answerField.textColor = UIColor.lightGrayColor()
        }
    }
    
    

}
class ButtonQuestionTableViewCell : UITableViewCell {
    
    @IBOutlet var  questionLabel : UILabel!
    @IBOutlet var  button1 : UIButton!
    @IBOutlet var  button2 : UIButton!
    @IBOutlet var  button3 : UIButton!
    @IBOutlet var  button4 : UIButton!
    @IBOutlet var  button5 : UIButton!
    @IBOutlet var  skipButton : UIButton!
    
    func loadItem( question: String , buttonText : [String] , cell : Int) {
        var buttons = [button1,button2,button3,button4,button5,skipButton]
        questionLabel.text = question
        questionLabel.lineBreakMode =  NSLineBreakMode.ByWordWrapping
        questionLabel.numberOfLines = 2
        questionLabel.sizeToFit()
        for j in 0...buttons.count-1 {
            buttons[j].setTitle("       ", forState: UIControlState.Normal)
        }
        for i in 0...buttonText.count-1 {
            buttons[i].setTitle(buttonText[i], forState: UIControlState.Normal)
            buttons[i].tag = i + (100 * cell)
            buttons[i].enabled = true
        }
        skipButton.enabled = true
        skipButton.hidden = false
        self.reloadInputViews()
    }
    
    
}
class QuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
   // var questions : [Question] = [Question(questionText : "test1", buttons: []), Question(questionText : "test2", buttons: []) , Question(questionText : "test2", buttons: ["button 1" , "button 2"])]
    var questions : [Question] = []
    override func viewDidLoad() {
        var nib = UINib(nibName: "TextFieldQuestionTableViewCell", bundle: nil)
        var nib2 = UINib(nibName: "ButtonQuestionTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TextFieldQuestionTableViewCell")
        tableView.registerNib(nib2, forCellReuseIdentifier: "ButtonQuestionTableViewCell")
        getQuestions()
       // tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        var swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard")
        
        swipe.direction = UISwipeGestureRecognizerDirection.Down
        
        self.view.addGestureRecognizer(swipe)
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.view.endEditing(true)
    }
    func dismissKeyboard() {
        
       // self.view.endEditing(true)
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var q : Question = questions[indexPath.row]
        if (q.buttons.count == 0 ){
        var cell:TextFieldQuestionTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("TextFieldQuestionTableViewCell") as! TextFieldQuestionTableViewCell
            cell.submitButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.skipButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        // this is how you extract values from a tuple
            cell.loadItem(q.questionText,cell: indexPath.row)
        
        return cell
        }else{
            var cell:ButtonQuestionTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ButtonQuestionTableViewCell") as! ButtonQuestionTableViewCell
            cell.button1.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.button2.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.button3.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.button4.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.button5.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.skipButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.loadItem(q.questionText, buttonText: q.buttons , cell: indexPath.row )
            
            return cell
        }
    }
    
    func buttonPressed( sender : UIButton) {
        var response = PFObject(className:"Response")
        var tag = sender.tag
        var buttonIndex : Int = tag%100
        var rowIndex : Int = (tag - buttonIndex) / 100
        
        if sender.titleLabel?.text == "Skip" {
            questions.removeAtIndex(rowIndex)
            
            tableView.reloadData()
            if questions.count == 0{
                //getQuestions()
                questionsAnswererd(self)
            }
            return
        }
        var question = questions[rowIndex]
         // question.questionText
        var responseText : String
        if buttonIndex == -1 || buttonIndex == 99 {
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowIndex, inSection: 0)) as! TextFieldQuestionTableViewCell
             responseText = cell.answerField.text
            print (question)
            print(responseText)
        }else{
             responseText = question.buttons[buttonIndex]
        }
        response["questionText"] = question.questionText
        response["responseText"] = responseText
        response["user"] = PFUser.currentUser()
        response.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("Object Saved")
            } else {
                print("ERROR: save error")
            }
        }
        questions.removeAtIndex(rowIndex)
        if questions.count == 0{
            //getQuestions()
            questionsAnswererd(self)
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("You selected cell #\(indexPath.row)!")
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    
    func getQuestions(){
        let query  = PFQuery(className:"Question")
        query.whereKey("active", equalTo: true)
        var lastQuestion =  PFUser.currentUser()!.valueForKey("lastQuestion")
        if lastQuestion == nil {
            lastQuestion = 0
        }
     
        /*
        var answerKeys = ["AnswerA","AnswerB","AnswerC","AnswerD","AnswerE"]
        var answers : [String] = []
        
        for a in answerKeys {
        //var answer = object[a] as! String
        var answer : String = object.objectForKey(a) as! String
        if answer != "" {
        answers += [answer]
        }
        
        }
        
        self.questions += [Question(questionText : question, buttons: answers)]
        */
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                //self.questions = []
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        
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
                        
                        self.questions += [Question(questionText : question, buttons: answers)]
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func questionsAnswererd(sender: AnyObject) {
        let alertController = UIAlertController(title: "All questions answered!", message:
            "Thanks!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion:  {
            
            self.performSegueWithIdentifier("questionToHome", sender: self)
        })
    }

    
}