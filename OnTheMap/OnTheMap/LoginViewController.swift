//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 23/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var udacityClient = UdacityClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the TMDB client
        //tmdbClient = TMDBClient.sharedInstance()
        
        udacityClient = UdacityClient.sharedInstance()
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func showError(errorMessage: String) {
        let alertView = UIAlertController(title: "Unsuccessful Login", message: errorMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        guard let username = usernameText.text, password = passwordText.text
            where username != "" && password != "" else {
                showError("Username / Password Required")
                return
        }
        
        udacityClient.authenticateWithLogin(username, password: password) {
            (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
                else {
                    self.showError(errorString!)
                }
            }
            
        }
    }
    
    
    @IBAction func WebLink(sender: AnyObject) {
        if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
}