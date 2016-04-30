//
//  StudentArray.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 30/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation
class StudentArray {
    static var sharedInstance = StudentArray()
    var studentArray = [StudentInformation]()
}