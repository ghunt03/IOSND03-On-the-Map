//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Gareth Hunt on 24/04/2016.
//  Copyright © 2016 ghunt03. All rights reserved.
//
import UIKit
import Foundation

class TableViewController: UIViewController {

    
    @IBOutlet weak var mapTableView: UITableView!

    var studentList = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentLocations()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getStudentLocations()
    }
    
    //Refresh function called from TabViewController when refresh button pressed
    func refresh() {
        getStudentLocations()
    }
    
    private func getStudentLocations() {
        ParseClient.sharedInstance.getStudents {
            (students, error) in
            guard (error == nil) else {
                performUIUpdatesOnMain {
                    self.showError(error!)
                }
                return
            }
            self.studentList = StudentArray.sharedInstance.studentArray
            performUIUpdatesOnMain {
                self.mapTableView.reloadData()
            }

        }
    }
    
    
    private func showError(errorMessage: String) {
        let alertView = UIAlertController(title: "On The Map", message: errorMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    
    
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MapTableCell")! as! MapTableCell
        let student = studentList[indexPath.row]
        cell.displayName!.text = student.fullName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = studentList[indexPath.row]
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
