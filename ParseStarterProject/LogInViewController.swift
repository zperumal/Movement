//
//  SignupViewController.swift
//  Movement
//
//  Created by Zara Perumal on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//


import UIKit
import Parse
import Locksmith

class LogInViewController: UIViewController {
    let service = "swiftLogin"
    let userAccount = "swiftLoginUser"

    override func viewDidAppear(animated: Bool) {
        let dictionary = Locksmith.loadDataForUserAccount( userAccount ,inService: service)
    
        if  dictionary != nil && dictionary?.isEmpty == false{            // User is already logged in, Send them to already logged in view.
            //self.performSegueWithIdentifier("logInViewSegue", sender: self)
            print ("loggin in!")

        }
    }
    
    @IBOutlet weak var savePasswordSwitch: UISwitch!

    @IBOutlet weak var kerberos: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func loginAction(sender: AnyObject) {
        let username = self.kerberos.text
        let password = self.password.text
        
        // Validate the text fields
        if username?.characters.count == 0 {
            let alert = UIAlertView(title: "Invalid", message: "Username cannot be empty", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else if username?.characters.count == 0 {
            let alert = UIAlertView(title: "Invalid", message: "Password cannot be empty", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else {
            if savePasswordSwitch.on{
                
            }
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("toHome") as! UIViewController
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })

                    
                } else {
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        }
    }
}
