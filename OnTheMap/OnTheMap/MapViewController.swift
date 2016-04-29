//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getStudentLocations()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func refresh() {
        getStudentLocations()
    }
    
    private func getStudentLocations() {
        /*
        Updates the sharedInstance of the studentList,
        then once updated calls the addLocations function
        */
        ParseClient.parseSharedInstance().getStudents {
            (students, error) in
            guard (error == nil) else {
                performUIUpdatesOnMain {
                    self.showError("Unable to access data")
                }
                return
            }
            self.addLocations()
        }
    }

    private func addLocations() {
        /*
        function to add the pins to the map view
        */
        performUIUpdatesOnMain {
            for annotation in self.mapView.annotations {
                self.mapView.removeAnnotation(annotation)
            }
            for student in StudentInformation.sharedInstance.studentList {
                self.mapView.addAnnotation(student.toMapAnnotation())
            }
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    private func showError(errorMessage: String) {
        // shows error alert view
        let alertView = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }

}