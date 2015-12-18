//
//  ParseUtilities.swift
//  Movement
//
//  Created by Zara Perumal on 12/10/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import Parse

class ParseNetworker : NSObject{
    func parseLogin(username : String, password : String ){
        
        // Send a request to login
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
            
            // Stop the spinner
            spinner.stopAnimating()
            
            if ((user) != nil) {
                //let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                //alert.show()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.performSegueWithIdentifier("toHome", sender: self)
                })
                
                
            } else {
                let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        })
    }
}