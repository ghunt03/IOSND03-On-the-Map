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
                print(error)
                return
            }
            guard let records = results[JSONResponseKeys.Results] as? [[String:AnyObject]] else {
                completionHandlerForStudents(result: nil, error: "Cannot find key '\(JSONResponseKeys.Results)' in \(results)")
                return
            }
            let studentRecords = StudentInformation.studentInformationFromResults(records)
            completionHandlerForStudents(result: studentRecords, error: nil)
        }
    }
}