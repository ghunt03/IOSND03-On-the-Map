//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    var session = NSURLSession.sharedSession()
    
    //Authentication State
    var sessionID: String? = nil
    var userID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    override init() {
        super.init()
    }
    
    // create request based on details of methods
    private func createRequest(methodType: String, methodURL: String, jsonData: String?) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(URL: UdacityClient.udacityURL(methodURL))
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = methodType
        if jsonData != nil {
            request.HTTPBody = jsonData!.dataUsingEncoding(NSUTF8StringEncoding)
        }
        return request
    }
    
    private func createTask(request: NSMutableURLRequest, completionHandlerForTask: (results: AnyObject!, error: NSError?)-> Void) ->NSURLSessionDataTask {
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in
            guard (error == nil) else {
                self.sendError("There was an error with your request \(error)",
                    errorDomain: "errorConnecting",
                    completionHandlerForError: completionHandlerForTask)
                return
            }
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.sendError("Your request returned a status code other than 2xx!", errorDomain: "invalidStatusCode", completionHandlerForError: completionHandlerForTask)
                return
            }
            guard let data = data else {
                self.sendError("No data was returned by the request!", errorDomain: "invalidData", completionHandlerForError: completionHandlerForTask)
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForTask)
        }
        task.resume()
        return task
    }


    
    
    //GET Method
    func taskForGETMethod(method: String, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void)  {
        let request = createRequest("GET", methodURL: method, jsonData: nil)
        createTask(request, completionHandlerForTask: completionHandlerForGET)
    }
    
    //POST Method
    func taskForPOSTMethod(method: String, jsonData: String, completionHandlerForPOST: (result: AnyObject!, error:NSError?) -> Void)  {
        let request = createRequest("POST", methodURL: method, jsonData: jsonData)
        createTask(request, completionHandlerForTask: completionHandlerForPOST)
        
    }
    
    //DELETe MEthod
    func taskForDELETESession(method: String, completionHandlerForDELETESession: (result: AnyObject!, error:NSError?) -> Void)  {
        let request = createRequest("DELETE", methodURL: method, jsonData: nil)
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        createTask(request, completionHandlerForTask: completionHandlerForDELETESession)
    }

    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            self.sendError("Could not parse the data as JSON: '\(data)'", errorDomain: "convertDataWithCompletionHandler", completionHandlerForError: completionHandlerForConvertData)
        }
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    //create URL
    class func udacityURL(withPathExtension: String? = nil) -> NSURL {
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        return components.URL!
    }
    
    //Send error -> creates NSError Message
    private func sendError(errorMessage: String, errorDomain: String, completionHandlerForError: (result: AnyObject!, error: NSError?) ->Void) {
        let userInfo = [NSLocalizedDescriptionKey: errorMessage,
            NSLocalizedFailureReasonErrorKey: errorDomain
        ]
        completionHandlerForError(result: nil, error: NSError(domain: errorDomain, code:1, userInfo: userInfo))
    }
    
    // substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }


    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }


}