//
//  ViewController.swift
//  xBeacon
//
//  Created by Leandro on 5/24/16.
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase

var buttonState: Bool = false

class ConnectViewController: UITableViewController {
    
    // Temporary values used for test with the simulator
    var users: [User] = []
  
    // Actions
    @IBOutlet weak var searchingSwitch: UISwitch!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    //var buttonState: Bool = false
    
    //UI Functions
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        
        performSegueWithIdentifier("Logout", sender: self)
    }
    
    // Operation vars
    private var searchingOperation = SearchingOperation()
    
    // Array of detected beacons
    private var detectedBeacons = [CLBeacon]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchingOperation.delegate = self
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        // searchingSwitch.on = false
        searchingSwitch.on ? (buttonState = true) : (buttonState = false)
        //switchChanged(searchingSwitch)
        print("leaving: " + String(buttonState))
    }
    
    override func viewWillAppear(animated: Bool) {
        searchingSwitch.on = buttonState
        //switchChanged(searchingSwitch)
        print("appearing: " + String(buttonState))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    /**
     Starts/stops the monitoring operation, depending on the state of the given switch.
     
     :param: monitoringSwitch The monitoring UISwitch instance.
     */
    @IBAction func switchChanged(monitoringSwitch: UISwitch) {
        monitoringSwitch.on ? searchingOperation.startSearchingForBeacons() : searchingOperation.stopSearchingForBeacons()
        
        if (monitoringSwitch.on) {
            print("ON")
            
            users = []
            /*
            users = [User.init(major: "63662", minor: "47622", tableView: self.tableView ),
                     User.init(major: "63291", minor: "54565", tableView: self.tableView ),
                     User.init(major: "22575", minor: "18251", tableView: self.tableView )]
            */
            /*
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
 */
        }
        else {
            print("OFF")
            users.removeAll()   // Remove all users when disconnecting?
            self.tableView.reloadData()
        }
    }
    
    
    //  * * * Table view functions * * * \\
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        
        // Configure the cell...
        let user = users[indexPath.row] as User
        
        cell.user = user
        
        return cell
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DetailedProfile" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
        
            if let selectedUserCell = sender as? UserCell {
                print("Cell selected " + selectedUserCell.userName.text!)
                print("UID: " + selectedUserCell.user.uid!)
            
                let indexPath = tableView.indexPathForCell(selectedUserCell)!
                let selectedUser = users[indexPath.row]
                profileViewController.currentUser = selectedUser
            }
        }
        else {

        }
    }
    
    
    @IBAction func backToHome(segue: UIStoryboardSegue) {
        
    }

    @IBAction func saveProfile(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func cancelEdit(segue: UIStoryboardSegue) {
        
    }
    
}

extension ConnectViewController: SearchingOperationDelegate {
    /**
     Triggered when the searching operation has started successfully.
     */
    func searchingOperationDidStartSuccessfully() {
        
    }
    
    /**
     Triggered by the searching operation when it has stopped successfully.
     */
    func searchingOperationDidStopSuccessfully() {
        
    }
    
    /**
     Triggered when the searching operation has failed to start.
     */
    //func searchingOperationDidFailToStart()
    
    /**
     Triggered when the monitoring operation has failed to start.
     */
    func monitoringOperationDidFailToStart() {
        self.searchingSwitch.on = false
    }
    
    /**
     Triggered when the advertising operation has failed to start.
     */
    func advertisingOperationDidFailToStart() {
        let title = "Bluetooth is off"
        let message = "It seems that Bluetooth is off. For advertising to work, please turn Bluetooth on."
        let cancelButtonTitle = "OK"
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction.init(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction);
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Triggered when the ranging operation has failed to start.
     */
    func rangingOperationDidFailToStart() {
        self.searchingSwitch.on = false
    }
    
    /**
     Triggered when the searching operation has failed to start due to the last authorization denial.
     */
    func searchingOperationDidFailToStartDueToAuthorization() {
        let title = "Missing Location Access"
        let message = "Location Access (Always) is required. Click Settings to update the location access settings."
        let cancelButtonTitle = "Cancel"
        let settingsButtonTitle = "Settings"
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction.init(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: settingsButtonTitle, style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(cancelAction);
        alertController.addAction(settingsAction);
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Triggered by the ranging operation when it has detected beacons belonging to a specific given beacon region.
     
     It updates the table view to show the newly-found beacons.
     
     :param: beacons An array of provided beacons that the ranging operation detected.
     :param: region A provided region whose beacons the operation is trying to range.
     */
    
    
    func rangingOperationDidRangeBeacons(beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        self.detectedBeacons = beacons as! [CLBeacon]
        var tempUsers: [User] = []
        var isNew: Bool = true
        
        // Find new beacons and append to a temporary list
        for beacon in detectedBeacons {
            isNew = true
            for user in users {
                if user.major == beacon.major.stringValue && user.minor == beacon.minor.stringValue {
                    isNew = false
                    break
                }
            }
            if isNew == true {
                tempUsers.append(User.init(major: beacon.major.stringValue, minor: beacon.minor.stringValue, tableView: self.tableView))
            }
        }

        // Append the rest if they are still within the region
        for user in users {
            for beacon in detectedBeacons {
                if user.major == beacon.major.stringValue && user.minor == beacon.minor.stringValue {
                    tempUsers.append(user)
                    break
                }
            }
        }
        
        users = tempUsers
        self.tableView.reloadData()
        
        /*
        for beacon in beacons as! [CLBeacon] {
            print("Beacon: \(beacon.major) \(beacon.minor)")
        }
        */
    }
}

