//
//  SearchingOperation.swift
//  xBeacon
//
//  Created by Stanley Phu on 5/24/16.
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreBluetooth
import Firebase
import FirebaseDatabase
import FirebaseAuth

protocol SearchingOperationDelegate {
    
    /**
    Triggered when the searching operation has started successfully.
    */
    func searchingOperationDidStartSuccessfully()
    
    /**
    Triggered by the searching operation when it has stopped successfully.
    */
    func searchingOperationDidStopSuccessfully()
    
    /**
    Triggered when the searching operation has failed to start.
    */
    //func searchingOperationDidFailToStart()
    
    /**
     Triggered when the monitoring operation has failed to start.
     */
    func monitoringOperationDidFailToStart()
    
    /**
     Triggered when the advertising operation has failed to start.
     */
    func advertisingOperationDidFailToStart()
    
    /**
     Triggered when the ranging operation has failed to start.
     */
    func rangingOperationDidFailToStart()
    
    /**
    Triggered when the searching operation has failed to start due to the last authorization denial.
    */
    func searchingOperationDidFailToStartDueToAuthorization()
    
    /**
     Triggered when the ranging operation has detected beacons belonging to a specific given beacon region.
     
     :param: beacons An array of provided beacons that the ranging operation detected.
     :param: region A provided region whose beacons the operation is trying to range.
     */
    func rangingOperationDidRangeBeacons(beacons: [AnyObject]!, inRegion region: CLBeaconRegion!)
}

class SearchingOperation: BeaconOperation {
    var delegate: SearchingOperationDelegate?
    
    /// An instance of a CBPeripheralManager, which is used for advertising a beacon to nearby devices.
    var peripheralManager = CBPeripheralManager(delegate: nil, queue: nil, options: nil)

    /**
        Starts the beacon searching process.
    */
    func startSearchingForBeacons() {
        activateLocationManagerNotifications()
        
        /*
        //Monitoring
        print("Turning on monitoring...")
        
        if !CLLocationManager.locationServicesEnabled() {
            print("Couldn't turn on monitoring: Location services are not enabled.")
            delegate?.monitoringOperationDidFailToStart()
            return
        }
        
        if !(CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion)) {
            print("Couldn't turn on region monitoring: Region monitoring is not available for CLBeaconRegion class.")
            delegate?.monitoringOperationDidFailToStart()
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            turnOnMonitoring()
        case .AuthorizedWhenInUse, .Denied, .Restricted:
            print("Couldn't turn on monitoring: Required Location Access (Always) missing.")
            delegate?.searchingOperationDidFailToStartDueToAuthorization()
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        }
        */
        
        
        //Advertising
        print("Turning on advertising...")
        
        if peripheralManager.state != .PoweredOn {
            print("Peripheral manager is off.")
            delegate?.advertisingOperationDidFailToStart()
            return
        }
        
        activatePeripheralManagerNotifications();
        
        turnOnAdvertising()
        
        
        //Ranging
        print("Turning on ranging...")
        
        if !CLLocationManager.locationServicesEnabled() {
            print("Couldn't turn on ranging: Location services are not enabled.")
            delegate?.rangingOperationDidFailToStart()
            return
        }
        
        if !CLLocationManager.isRangingAvailable() {
            print("Couldn't turn on ranging: Ranging is not available.")
            delegate?.rangingOperationDidFailToStart()
            return
        }
        
        if !locationManager.rangedRegions.isEmpty {
            print("Didn't turn on ranging: Ranging already on.")
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            turnOnRanging()
        case .Denied, .Restricted:
            print("Couldn't turn on ranging: Required Location Access (When In Use) missing.")
            delegate?.searchingOperationDidFailToStartDueToAuthorization()
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func turnOnMonitoring() {
        locationManager.startMonitoringForRegion(beaconRegion)
        print("Monitoring turned on for region: \(beaconRegion)")
        delegate?.searchingOperationDidStartSuccessfully()
    }
    
    func turnOnAdvertising() {
        
        let rootRef = FIRDatabase.database().reference()
        
        //profile for user
        let profileRef = rootRef.child("profile")
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        profileRef.child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let majorValue = snapshot.value!["Major"] as! Int
            let minorValue = snapshot.value!["Minor"] as! Int
            
            let major: CLBeaconMajorValue = CLBeaconMajorValue(majorValue)
            let minor: CLBeaconMinorValue = CLBeaconMajorValue(minorValue)
            let region: CLBeaconRegion = CLBeaconRegion(proximityUUID: self.beaconRegion.proximityUUID, major: major, minor: minor, identifier: self.beaconRegion.identifier)
            let beaconPeripheralData: NSDictionary = region.peripheralDataWithMeasuredPower(nil) as NSDictionary
            
            self.peripheralManager.startAdvertising(beaconPeripheralData as? [String : AnyObject])
            
            print("Turning on advertising for region: \(region).")
            
            
        }) { (error) in
            print(error.localizedDescription)
        }

        
    }
    
    func turnOnRanging() {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        print("Ranging turned on for beacons in region: \(beaconRegion)")
        delegate?.searchingOperationDidStartSuccessfully()
    }
    
    /**
     Sets the peripheral manager delegate to self. It is called when an instance is ready to process peripheral
     manager delegate calls.
     */
    func activatePeripheralManagerNotifications() {
        peripheralManager.delegate = self;
    }
    
    /**
     Sets the peripheral manager delegate to nil. It is called when an instance is ready to stop processing
     peripheral manager delegate calls.
     */
    func deactivatePeripheralManagerNotifications() {
        peripheralManager.delegate = nil;
    }
    
    /**
        Stops the beacon searching process.
    */
    func stopSearchingForBeacons() {
        // Monitoring
        locationManager.stopMonitoringForRegion(beaconRegion)
        print("Turned off monitoring")
        //delegate?.searchingOperationDidStopSuccessfully()
        
        // Advertising
        peripheralManager.stopAdvertising()
        deactivatePeripheralManagerNotifications();
        print("Turned off advertising.")
        //delegate?.searchingOperationDidStopSuccessfully()
        
        // Ranging
        if locationManager.rangedRegions.isEmpty {
            print("Didn't turn off ranging: Ranging already off.")
            return
        }
        
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
        
        delegate?.searchingOperationDidStopSuccessfully()
        
        print("Turned off ranging.")
    }
}

// MARK: - CBPeripheralManagerDelegate methods
extension SearchingOperation: CBPeripheralManagerDelegate
{
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil {
            print("Couldn't turn on advertising: \(error)")
            delegate?.advertisingOperationDidFailToStart()
        }
        
        if peripheralManager.isAdvertising {
            print("Turned on advertising.")
            delegate?.searchingOperationDidStartSuccessfully()
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheralManager.state == .PoweredOff {
            print("Peripheral manager is off.")
            delegate?.advertisingOperationDidFailToStart()
        } else if peripheralManager.state == .PoweredOn {
            print("Peripheral manager is on.")
            turnOnAdvertising()
        }
    }
}

// MARK: Location manager delegate methods
extension SearchingOperation
{
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            print("Location Access (Always) granted!")
            delegate?.searchingOperationDidStartSuccessfully()
            turnOnRanging()
        } else if status == .AuthorizedWhenInUse {
            print("Location Access (When In Use) granted!")
            delegate?.searchingOperationDidStartSuccessfully()
            turnOnRanging()
        } else if status == .Denied || status == .Restricted {
            print("Location Access (When In Use) denied!")
            delegate?.rangingOperationDidFailToStart()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        delegate?.rangingOperationDidRangeBeacons(beacons, inRegion: region)
        //print("Found beacon.")
        //print("Count: \(beacons.count)")
        for beacon in beacons as! [CLBeacon] {
            //print("Beacon \(beacon): \(beacon.major) \(beacon.minor)")
            let majorminorKey = String(beacon.major) + " " + String(beacon.minor)
            let rootRef = FIRDatabase.database().reference()
            //setup ref profile
            let majorminorRef = rootRef.child("majorminor")
            
            
            

            //Right now just prints the uid, but can use the uid with the profile db to get name/fb/etc
            majorminorRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                // Get user value
                if(snapshot.hasChild(majorminorKey)){
                    let foundUserID = snapshot.value![majorminorKey] as! String
                    print("This is a user whose uid is: " + foundUserID)
                
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
            
            
            
            
        }
    }
}




