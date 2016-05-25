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

class ViewController: UIViewController {
  
    // Actions
    @IBOutlet weak var searchingSwitch: UISwitch!
    
    // Operation vars
    private var searchingOperation = SearchingOperation()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        }
        else {
            print("OFF")
        }
    }

}

extension ViewController: SearchingOperationDelegate {
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
        for beacon in beacons as! [CLBeacon] {
            print("Beacon: " + String(beacon.major) + " " + String(beacon.minor))
        }
    
    }
}

