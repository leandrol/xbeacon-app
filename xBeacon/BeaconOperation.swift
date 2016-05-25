//
//  BeaconOperation.swift
//  xBeacon
//
//  Created by Stanley Phu on 5/24/16.
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import Foundation
import CoreLocation

/// Provides a base class for all the operations that the app can perform.
class BeaconOperation: NSObject, CLLocationManagerDelegate
{
  /// An instance of CLLocationManager to provide monitoring and ranging facilities.
  lazy var locationManager: CLLocationManager = CLLocationManager()
  
  /// The beacon region that will be used as the reference for monitoring and ranging.
  let beaconRegion: CLBeaconRegion = {
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!, identifier: "Identifier")
    region.notifyEntryStateOnDisplay = true
    return region
  }()
  
  /**
   Sets the location manager delegate to self. It is called when an instance is ready to process location
   manager delegate calls.
   */
  func activateLocationManagerNotifications() {
    locationManager.delegate = self
  }
}
