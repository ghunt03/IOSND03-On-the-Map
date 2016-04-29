//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//
import MapKit
import Foundation
struct StudentInformation {
    let objectId: String
    let userId: String
    let firstName: String
    let lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    let fullName: String


    static var sharedInstance = StudentInformation()
    var studentList = [StudentInformation]()
    
    
    init() {
        self.objectId = ""
        self.userId = ""
        self.firstName = ""
        self.lastName = ""
        self.mapString = ""
        self.mediaURL = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.fullName = "\(firstName) \(lastName)"
    }
    
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
    
    mutating func updateLocation(latitude: Double, longitude: Double, location: String) {
        self.mapString = location
        self.latitude = latitude
        self.longitude = longitude
    }
    
    mutating func updateURL(url: String) {
        self.mediaURL = url
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
    
    func toMapAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = fullName
        annotation.subtitle = (mediaURL ?? mapString)
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return annotation
    }
    
}

