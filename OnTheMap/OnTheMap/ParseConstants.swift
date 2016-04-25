//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

extension ParseClient {
    struct Constants {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes/StudentLocation"
    }
    
    struct Methods {
        static let DeleteObjectData = "/{object_id}"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Where = "where"
        static let OrderBy = "order"
    }
    
    //Use as default parameters
    struct ParameterValues {
        static let Limit = 100
        static let Skip = 0
        static let OrderBy = "-updatedAt"
    }
    
    struct URLKeys {
        static let ObjectId = "object_id"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let URL = "mediaURL"
        static let ObjectId = "objectId"
        static let UserId = "uniqueKey"
    }
}