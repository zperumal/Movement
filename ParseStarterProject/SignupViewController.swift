//
//  SignupViewController.swift
//  Movement
//
//  Created by Zara Perumal on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//


import UIKit
import Parse

class SignupViewController: UIViewController {
    
    @IBOutlet weak var kerberos: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmpassword: UITextField!
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
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "submitSignup"{
            return signUpAction()
        }
        return true
    }
    func signUpAction() -> Bool {
        
        let kerberosText = self.kerberos.text
        let passwordText = self.password.text
        let passwordConfirmationText = self.confirmpassword.text
        
        // Validate the text fields
        if passwordText != passwordConfirmationText {
            let alert = UIAlertView(title: "Invalid", message: "Passwords don't match", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else if kerberosText?.characters.count == 0 {
            let alert = UIAlertView(title: "Invalid", message: "Kerberos cannot be left blank", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else if  passwordText?.characters.count < 8 {
            let alert = UIAlertView(title: "Invalid", message: "Password must be greater than 8 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            newUser.username = kerberosText
            newUser.password = passwordText
            newUser.email = kerberosText! + "@mit.edu"
            
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                } else {
                    let alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                }
            })
            return true;
        }
        return false;
    }
}
