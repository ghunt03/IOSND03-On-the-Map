//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

class ParseClient: NSObject {

    // shared session
    var session = NSURLSession.sharedSession()
    
    
    override init() {
        super.init()
    }
    
    // create request based on details of methods
    private func createRequest(methodType: String, methodURL: String, parameters: [String:AnyObject], jsonData: String?) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(URL: ParseClient.parseURLFromParameters(parameters, withPathExtension: methodURL))
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
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
                self.sendError("There was an error with your request \(error)", errorDomain: "errorConnecting", completionHandlerForError: completionHandlerForTask)
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
    func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: (results: AnyObject!, error: NSError?)->Void) -> NSURLSessionDataTask {
        
        let request = createRequest("GET", methodURL: "", parameters: parameters, jsonData: nil)
        return createTask(request, completionHandlerForTask: completionHandlerForGET)
    }
    
    // POST Function
    func taskForPOSTMethod(parameters: [String:AnyObject], jsonData: String, completionHandlerForPOST: (results: AnyObject!, error: NSError?)->Void) ->NSURLSessionDataTask {
        
        let request = createRequest("POST", methodURL: "", parameters: parameters, jsonData: jsonData)
        return createTask(request, completionHandlerForTask: completionHandlerForPOST)
    }
    
    // DELETE Function
    func taskForDELETEMethod(method: String, completionHandlerForDELETE: (results: AnyObject!, error: NSError?)->Void) ->NSURLSessionDataTask {
        let parameters = [String:AnyObject]()
        let request = createRequest("DELETE", methodURL: method, parameters: parameters, jsonData: nil)
        return createTask(request, completionHandlerForTask: completionHandlerForDELETE)
        
    }
    
    // UPDATE FUNCTION
    func taskForPUTMethod(method: String, jsonData: String, completionHandlerForPUT: (results: AnyObject!, error: NSError?)->Void) ->NSURLSessionDataTask {
        let parameters = [String:AnyObject]()
        let request = createRequest("PUT", methodURL: method, parameters: parameters, jsonData: jsonData)
        return createTask(request, completionHandlerForTask: completionHandlerForPUT)
    }

    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            self.sendError("Could not parse the data as JSON: '\(data)'", errorDomain: "convertDataWithCompletionHandler", completionHandlerForError: completionHandlerForConvertData)
        }
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }

   

    
    //Create URL From parameters
    class func parseURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
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
    
    class func parseSharedInstance() -> ParseClient {
        struct Singleton {
            static var parseSharedInstance = ParseClient()
        }
        return Singleton.parseSharedInstance
    }
}