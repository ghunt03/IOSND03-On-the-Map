//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//
import UIKit
import Foundation

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var parseClient = ParseClient()
    var students: [StudentInformation] = [StudentInformation]()
    
    
    @IBOutlet weak var mapTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        parseClient.getStudents {
            (students, error) in
            if let students = students {
                self.students = students
                performUIUpdatesOnMain {
                    self.mapTableView.reloadData()
                }
            }
            else {
                print(error)
            }
        }
        
    }
    private func showError(errorMessage: String) {
        let alertView = UIAlertController(title: "On The Map", message: errorMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MapTableCell")! as! MapTableCell
        let student = students[indexPath.row]
        cell.displayName.text = "\(student.firstName) \(student.lastName)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students[indexPath.row]
        if let url = NSURL(string: student.mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            showError("No valid URL Available")
        }
        
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

