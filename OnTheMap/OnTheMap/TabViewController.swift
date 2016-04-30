//
//  TabViewController.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 26/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
class TabViewController: UITabBarController {
    
    //MARK: Outlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    //MARK: Variables
    let udacityClient = UdacityClient.sharedInstance
    let parseClient = ParseClient.sharedInstance
    
    

    //MARK: Actions for button pressed
    @IBAction func postButtonPressed(sender: AnyObject) {
        // check if entry exists
        parseClient.getLocation(udacityClient.userID!) {
            (result, error) in
            if (result?.count > 0) {
                performUIUpdatesOnMain {
                    let alertView = UIAlertController(title:nil,message: "You have already checked-in would you like to update your location?", preferredStyle: UIAlertControllerStyle.Alert)
                    alertView.addAction(UIAlertAction(title: "Overwrite", style: .Default) {
                            (action) in
                            self.openPostScreen(result![0])
                        })
                    alertView.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))

                    self.presentViewController(alertView, animated: true, completion: nil)
                }
            }
            else {
                //open modal
                performUIUpdatesOnMain {
                    self.openPostScreen(nil)
                }
            }
        }
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        /*
        Delete udacity session
        
        revert to login screen
        */
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let fbLoginManager = FBSDKLoginManager()
            FBSDKLoginManager.logOut(fbLoginManager)()
        }
        udacityClient.logout() {
            (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            else {
                print(errorString)
            }
        }
        
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        
        if selectedViewController!.isKindOfClass(MapViewController) {
            let controller = selectedViewController as! MapViewController
            controller.refresh()
        }
        else if selectedViewController!.isKindOfClass(TableViewController) {
            let controller = selectedViewController as! TableViewController
            controller.refresh()
        } else {
            
        }
        
    }
    
    
    
    //MARK: UI functions
    private func openPostScreen(student: StudentInformation?) {
        let infoPostController = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        infoPostController.student = student
        self.presentViewController(infoPostController, animated: true) {
        
        }
    }
    
    private func showError(errorMessage: String) {
        let alertView = UIAlertController(title: "Check-In Error", message: errorMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
}