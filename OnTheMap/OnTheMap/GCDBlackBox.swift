//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 23/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}