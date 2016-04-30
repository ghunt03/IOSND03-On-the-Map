//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 23/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import UIKit

import FBSDKLoginKit
// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var udacityLoginButton: UIButton!

    @IBOutlet weak var signUpButton: UIButton!
    var udacityClient = UdacityClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            
           
        }
        else
        {
            fbLoginButton.delegate = self;
            fbLoginButton.readPermissions = ["public_profile", "email"]
            FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
            
        }
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if ((error) != nil)
        {
            // Process error
            self.showError(error.localizedDescription)
        }
        else if result.isCancelled {
            // Handle cancellations
            self.showError("Login cancelled")
        }
        else {
            // Do work
            setUIEnabled(false)
            let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            udacityClient.authenticateWithFB(accessToken) {
                (success, errorString) in
                performUIUpdatesOnMain {
                    if success {
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
                        self.setUIEnabled(true)
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                    else {
                        self.showError(errorString!)
                    }
                }
                
            }
        }
    }
    
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
        })
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
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
        setUIEnabled(false)
        
        udacityClient.authenticateWithLogin(username, password: password) {
            (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
                    self.setUIEnabled(true)
                    self.presentViewController(controller, animated: true, completion: nil)
                }
                else {
                    self.showError(errorString!)
                    self.setUIEnabled(true)
                }
            }
            
        }
    }
    
    
    @IBAction func WebLink(sender: AnyObject) {
        if let url = NSURL(string: UdacityClient.Constants.SignUpUrl) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    private func setUIEnabled(enabled: Bool) {

        usernameText.enabled = enabled
        passwordText.enabled = enabled
        fbLoginButton.enabled = enabled
        udacityLoginButton.enabled = enabled
        signUpButton.enabled = enabled
        // adjust button alpha
        if enabled {
            udacityLoginButton.alpha = 1.0
            fbLoginButton.alpha = 1.0
            signUpButton.alpha = 1.0
            activityIndicator.stopAnimating()
        } else {
            udacityLoginButton.alpha = 0.5
            fbLoginButton.alpha = 0.5
            signUpButton.alpha = 0.5
            activityIndicator.startAnimating()
        }
    }

    
}