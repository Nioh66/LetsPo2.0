//
//  LocationManager.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/7.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import CoreLocation
@objc protocol LocationManagerDelegate
{
    func locationManager(updatedUserLocation coordinate: CLLocation)
    @objc optional func locationManager(userDidEnterRegion region: CLRegion)
    @objc optional func locationManager(userDidExitRegion region: CLRegion)
}


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    public var delegate: LocationManagerDelegate?
    
    public override init(){
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.requestAlwaysAuthorization()
        
    }
 
    public func startUpdate(){
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdate(){
        locationManager.stopUpdatingLocation()
    }
    public func stopRegionMonitoring(region: CLCircularRegion){
        locationManager.stopMonitoring(for: region)
    }
    
    
    public func startRegionMonitoring(region: CLCircularRegion){
        print("CREATED REGION: \(region.identifier) - \(locationManager.monitoredRegions.count)")
        locationManager.requestState(for: region)
        locationManager.startMonitoring(for: region)
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard locations.last != nil else
        { return }
        
        delegate?.locationManager(updatedUserLocation: locations.last!)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("\n Location Manager Log:: Fail with location manager \(error.localizedDescription)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion){
        delegate?.locationManager!(userDidEnterRegion: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        delegate?.locationManager!(userDidExitRegion: region)
    }
    
    
    
}

