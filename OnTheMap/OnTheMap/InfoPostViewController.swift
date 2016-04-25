//
//  InfoPostViewController.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class InfoPostViewController: UIViewController {
    
    

    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    
    let udacityClient = UdacityClient.sharedInstance()
    let parseClient = ParseClient.parseSharedInstance()
    
    var location: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        submitButton.hidden = true
        questionLabel.text = "Where are you studying from today?"
        inputText.placeholder = "Location"
        inputText.text = ""
    }
    
    @IBAction func findOnMapPressed(sender: AnyObject) {
        location = inputText.text!
        if location != "" {
            var pointAnnotation:MKPointAnnotation!
            var pinAnnotationView:MKPinAnnotationView!
            let localSearchRequest:MKLocalSearchRequest! = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = location
            let localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
                if localSearchResponse == nil{
                    self.showError("Cannot find location")
                }
                else {
                    self.latitude = localSearchResponse!.boundingRegion.center.latitude
                    self.longitude = localSearchResponse!.boundingRegion.center.longitude
                    
                    
                    pointAnnotation = MKPointAnnotation()
                    pointAnnotation.title = self.location
                    pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                    pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
                    self.mapView.centerCoordinate = pointAnnotation.coordinate
                    self.mapView.addAnnotation(pinAnnotationView.annotation!)
                    
                    self.findOnMapButton.hidden = true
                    self.submitButton.hidden = false
                    self.inputText.placeholder = "URL"
                    self.inputText.text = ""
                    self.questionLabel.text = "Please enter URL"
                }
            }
            
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        
        
        let student = StudentInformation(objectID: "",
            userID: udacityClient.userID!,
            firstName: udacityClient.firstName!,
            lastname: udacityClient.lastName!,
            mapstring: location,
            url: inputText.text!,
            latitude: latitude,
            longitude: longitude
        )
        
        ParseClient.parseSharedInstance().postStudent(student) {
                (result, error) in
            if (error==nil) {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            else {
                self.showError("Error saving location, please try again")
            }
        }

    }
    
    
    @IBAction func deletePressed(sender: AnyObject) {
        //find entries

        parseClient.getLocation(udacityClient.userID!) {
            (result, error) in
            if (error == nil) {
                for student in result! {
                    self.parseClient.deleteLocation(student.objectId) {
                        (result, error) in
                        if (error == nil) {
                            performUIUpdatesOnMain {
                                self.showError("Entries deleted")
                            }
                        }
                        else {
                            performUIUpdatesOnMain {
                                self.showError(error!)
                            }
                        }
                    }
                }
            }
            else {
                performUIUpdatesOnMain {
                    self.showError(error!)
                }
            }
        }
    }
    
    private func showError(errorMessage: String) {
        let alertView = UIAlertController(title: "Check-In Error", message: errorMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
}