//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let SignUpUrl = "https://www.udacity.com/account/auth#!/signup"
    }
    
    
    struct Methods {
        static let Session = "/session"
        static let UserData = "/users/{user_id}"
    }
    
    struct URLKeys {
        static let UserID = "user_id"
    }
    
    struct JSONResponseKeys {
        static let SessionDetails = "session"
        static let SessionId = "id"
        static let AccountDetails = "account"
        static let UserDetails = "user"

        static let UserId = "key"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
}