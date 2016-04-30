//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func getStudents(completionHandlerForStudents: (result: [StudentInformation]?, error: String?)->Void) {
        let parameters = [
            ParameterKeys.Limit: ParameterValues.Limit,
            ParameterKeys.OrderBy: ParameterValues.OrderBy
        ]
        taskForGETMethod(parameters as! [String : AnyObject]) {
            (results, error) in
            guard (error == nil) else {
                completionHandlerForStudents(result: nil, error: "Unable to download data")
                return
            }
            guard let records = results[JSONResponseKeys.Results] as? [[String:AnyObject]] else {
                completionHandlerForStudents(result: nil, error: "Cannot find key '\(JSONResponseKeys.Results)' in \(results)")
                return
            }
            StudentArray.sharedInstance.studentArray = StudentInformation.studentInformationFromResults(records)
            
            completionHandlerForStudents(result: StudentArray.sharedInstance.studentArray, error: nil)
        }
    }
    
    func addLocation(student: StudentInformation, completionHandlerForPostStudent: (result: StudentInformation?, error: String?)->Void) {
        let parameters = [String:AnyObject]()
        let jsonData = student.toJSON()
        taskForPOSTMethod(parameters, jsonData: jsonData) {
            (results, error) in
            guard (error == nil) else {
                completionHandlerForPostStudent(result: nil, error:error?.localizedDescription)
                return
            }
            completionHandlerForPostStudent(result: student, error:nil)
        }
    }
    
    func deleteLocation(objectId: String, completionHandlerForDeletObject: (result: AnyObject?, error: String?)->Void) {
        var mutableMethod: String = Methods.DeleteObjectData
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: URLKeys.ObjectId, value: objectId)!
        taskForDELETEMethod(mutableMethod) {
            (results, error) in
            guard (error == nil) else {
                print(error)
                return
            }
            completionHandlerForDeletObject(result: results, error: nil)
            
        }
    }
    func updateLocation(student: StudentInformation, completionHandlerForPutStudent: (result: StudentInformation?, error: String?)->Void) {
        
        let jsonData = student.toJSON()
        var mutableMethod: String = Methods.UpdateObjectData
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: URLKeys.ObjectId, value: student.objectId)!
        
        taskForPUTMethod(mutableMethod, jsonData: jsonData) {
            (results, error) in
            guard (error == nil) else {
                completionHandlerForPutStudent(result: nil, error:error?.localizedDescription)
                return
            }
            completionHandlerForPutStudent(result: student, error:nil)
        }
    }

    
    
    
    func getLocation(userId: String, completionHandlerForLocation: (result: [StudentInformation]?, error: String?)->Void) {
        let parameters = [
            ParameterKeys.Where: "{\"uniqueKey\": \"\(userId)\"}"
        ]
        taskForGETMethod(parameters) {
            (results, error) in
            guard (error == nil) else {
                completionHandlerForLocation(result: nil, error:error?.localizedDescription)
                return
            }
            guard let records = results[JSONResponseKeys.Results] as? [[String:AnyObject]] else {
                completionHandlerForLocation(result: nil, error: "Cannot find key '\(JSONResponseKeys.Results)' in \(results)")
                return
            }
            let studentRecords = StudentInformation.studentInformationFromResults(records)
            completionHandlerForLocation(result: studentRecords, error: nil)
        }
    }
}