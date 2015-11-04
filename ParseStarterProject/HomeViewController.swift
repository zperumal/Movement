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


class HomeViewController: UIViewController {
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var kerberos: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmpassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        setPostLabel()
        //syncData()
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func sync(){
        syncData()
    }
    func syncData(){
        let hk = HealthKit()
        if hk.checkAuthorization(){
        hk.lastDaysSteps() { error in
          //  print(error)
        }
        }
        PFUser.currentUser()!.incrementKey("posts" )
        setPostLabel()
    }
    func setPostLabel(){
        
        let posts = String(PFUser.currentUser()!.valueForKey("posts")! )
        print(posts)
        postLabel.text = posts
    }
}