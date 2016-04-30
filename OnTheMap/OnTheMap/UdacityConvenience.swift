//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import UIKit
import Foundation

extension UdacityClient {
    
    func authenticateWithLogin(username: String, password: String, completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
        let jsonData = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        authenticateSession(jsonData) {
            (success, errorString) in
            completionHandlerForLogin(success: success, errorString: errorString)
        }
    }
    func authenticateWithFB(fbAccessToken: String, completionHandlerForFBLogin: (success: Bool, errorString: String?) -> Void) {
        let jsonData = "{\"facebook_mobile\": {\"access_token\": \"\(fbAccessToken)\"}}"
        authenticateSession(jsonData) {
            (success, errorString) in
            completionHandlerForFBLogin(success: success, errorString: errorString)
        }
    }
    
    func logout(completionHandlerForLogout: (success: Bool, errorString: String?) ->Void) {
        taskForDELETESession(Methods.Session) {
            (success, error) in
            if (error == nil) {
                completionHandlerForLogout(success: true, errorString: nil)
            }
            else {
                print(error)
                completionHandlerForLogout(success: false, errorString: "Error logging out")
            }
            
        }
    }
    
    
    private func authenticateSession(jsonData: String, completionHandlerForAuth: (success: Bool, errorString: String?) ->Void) {
        getSessionDetails(jsonData) {
            (success, sessionID, userID, errorString) in
            if success {
                self.sessionID = sessionID
                self.userID = userID
                self.getUserDetails(userID!) {
                    (success, firstName, lastName, errorString) in
                    if success {
                        self.firstName = firstName
                        self.lastName = lastName
                        completionHandlerForAuth(success: success, errorString: errorString)
                    }
                    else {
                        completionHandlerForAuth(success: success, errorString: errorString)
                    }
                }
                
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }

    
    
    private func getSessionDetails(jsonData: String, completionHandlerForSession: (success:Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        taskForPOSTMethod(Methods.Session, jsonData: jsonData) { (results, error) in
            guard (error == nil) else {
                if (error?.localizedFailureReason == "invalidStatusCode") {
                    completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Invalid Login Details")
                }
                else {
                    completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Unable to connect. No connection available")
                }
                return
            }
            
            //GUARD: check if Session Details exist in
            guard let sessionDetails = results[JSONResponseKeys.SessionDetails] as? [String: AnyObject] else {
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Cannot find key '\(JSONResponseKeys.SessionDetails)' in \(results)")
                return
            }
            guard let sessionId = sessionDetails[JSONResponseKeys.SessionId] as? String else {
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Cannot find key '\(JSONResponseKeys.SessionId)' in \(sessionDetails)")
                return
            }
            guard let accountDetails = results[JSONResponseKeys.AccountDetails] as? [String: AnyObject] else {
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Cannot find key '\(JSONResponseKeys.SessionDetails)' in \(results)")
                return
            }
            guard let userId = accountDetails[JSONResponseKeys.UserId] as? String else {
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Cannot find key '\(JSONResponseKeys.UserId)' in \(accountDetails)")
                return
            }
            completionHandlerForSession(success: true, sessionID: sessionId, userID: userId, errorString: nil)
           
        }
    }
    
    private func getUserDetails(userID: String, completionHandlerForUserDetails: (success: Bool, firstName: String?, lastName: String?,errorString: String?) ->Void) {
        var mutableMethod: String = Methods.UserData
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: URLKeys.UserID, value: String(userID))!
        taskForGETMethod(mutableMethod) {
            (results, error) in
            guard let userDetails = results[JSONResponseKeys.UserDetails] as? [String:AnyObject] else {
                completionHandlerForUserDetails(success: false, firstName: nil, lastName: nil, errorString: "Cannot find key '\(JSONResponseKeys.UserDetails)' in \(results)")
                return
            }
            
            guard let firstName = userDetails[JSONResponseKeys.FirstName] as? String, lastName = userDetails[JSONResponseKeys.LastName] as? String else {
                completionHandlerForUserDetails(success: false, firstName: nil, lastName: nil, errorString: "Cannot find keys '\(JSONResponseKeys.FirstName)' or '\(JSONResponseKeys.LastName)'  in \(userDetails)")
                return
            }
            completionHandlerForUserDetails(success: true, firstName: firstName, lastName: lastName, errorString: nil)
        }
    }
    
    
    
}
