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

class InfoPostViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets

    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    //MARK: Variables
    let udacityClient = UdacityClient.sharedInstance
    let parseClient = ParseClient.sharedInstance
    
    var student: StudentInformation?
    var location: String = ""
    var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputText.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //check if student passed in from previous view controller
        if (student != nil) {
            location = (student?.mapString)!
            url = (student?.mediaURL)!
            addPointToMap()
        } else {
            //if student doesnt exist create new instance
            student = StudentInformation(objectID: "", userID: udacityClient.userID!, firstName: udacityClient.firstName!, lastname: udacityClient.lastName!, mapstring: location, url: url, latitude: 0, longitude: 0)
        }
        
        questionLabel.text = "Where are you studying from today?"
        inputText.placeholder = "Location"
        inputText.text = location
        submitButton.hidden = true
    }
    
    //MARK: Button Acttions
    
    @IBAction func findOnMapPressed(sender: AnyObject) {
        location = inputText.text!
        
        if location != "" {
            setUIEnabled(false)
            let localSearchRequest:MKLocalSearchRequest! = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = location
            let localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.startWithCompletionHandler {
                (localSearchResponse, error) -> Void in
                guard (localSearchResponse != nil) else {
                    self.showError("Cannot find location")
                    self.setUIEnabled(true)
                    return
                }
                self.student?.updateLocation(localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude, location: self.location)
                self.clearPointsFromMap()
                self.addPointToMap()
                
                
                self.findOnMapButton.hidden = true
                self.submitButton.hidden = false
                self.inputText.placeholder = "URL"
                self.inputText.text = self.student?.mediaURL
                self.questionLabel.text = "Please enter URL"
                self.setUIEnabled(true)
                
            }
            
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        student?.updateURL(inputText.text!)
        if student?.objectId == "" {
            //Create new entry
            parseClient.addLocation(student!) {
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
        } else {
            //update existing entry
            parseClient.updateLocation(student!) {
                (result, error) in
                if (error==nil) {
                    performUIUpdatesOnMain {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                else {
                    performUIUpdatesOnMain {
                        self.showError("Error saving location, please try again")
                    }
                }
            }
        }
    }
    
    @IBAction func deletePressed(sender: AnyObject) {
        //find existing entries for current student
        parseClient.getLocation(udacityClient.userID!) {
            (result, error) in
            guard (error == nil) else {
                performUIUpdatesOnMain {
                    self.showError(error!)
                }
                return
            }
            for student in result! {
                //delete locations by object id
                self.parseClient.deleteLocation(student.objectId) {
                    (result, error) in
                    guard (error == nil) else {
                        performUIUpdatesOnMain {
                            self.showError(error!)
                        }
                        return
                    }
                    performUIUpdatesOnMain {
                        self.showError("Entries deleted")
                    }
                }
            }
        }
    }
    
    //MARK: Map Points
    private func clearPointsFromMap() {
        //remove points from map
        for annotation in mapView.annotations {
            self.mapView.removeAnnotation(annotation)
        }
        
    }
    
    private func addPointToMap() {
        // add points to map
        let pointAnnotation = student?.toMapAnnotation()
        let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        self.mapView.centerCoordinate = pointAnnotation!.coordinate
        self.mapView.addAnnotation(pinAnnotationView.annotation!)
    }
    
    
    
    
    
    
    //MARK: UI Controls
    
    private func showError(errorMessage: String) {
        let alertView = UIAlertController(title: "Check-In Error", message: errorMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    private func setUIEnabled(enabled: Bool) {
        
        // adjust button alpha
        if enabled {
            findOnMapButton.alpha = 1.0
            cancelButton.alpha = 1.0
            submitButton.alpha = 1.0
            activityView.stopAnimating()
        } else {
            findOnMapButton.alpha = 0.5
            cancelButton.alpha = 0.5
            submitButton.alpha = 0.5
            activityView.startAnimating()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
}