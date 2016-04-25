//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation
struct StudentInformation {
    let objectId: String
    let userId: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let fullName: String

    
    init(dictionary: [String:AnyObject]) {
        objectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as! String
        userId = dictionary[ParseClient.JSONResponseKeys.UserId] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.URL] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
        fullName = "\(firstName) \(lastName)"
        
    }
    init(objectID: String, userID:String, firstName: String, lastname: String, mapstring: String, url: String, latitude: Double, longitude: Double) {
        self.objectId = objectID
        self.userId = userID
        self.firstName = firstName
        self.lastName = lastname
        self.mapString = mapstring
        self.mediaURL = url
        self.latitude = latitude
        self.longitude = longitude
        self.fullName = "\(firstName) \(lastName)"
    }
    
    static func studentInformationFromResults(results: [[String:AnyObject]]) -> [StudentInformation] {
        var records = [StudentInformation]()
        for result in results {
            records.append(StudentInformation(dictionary: result))
        }
        return records
    }
    
    func toJSON() ->String {
        return "{\"uniqueKey\": \"\(userId)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
    }
    
}

