//
//  LocationManager.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/7.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

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
        print("stop = \(region)")
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
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion){
        guard ((delegate?.locationManager!(userDidEnterRegion: region)) != nil) else {return}
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        guard ((delegate?.locationManager!(userDidExitRegion: region)) != nil) else {return}
    }
    
    public func isMonitoringAvailable(lat:CLLocationDegrees,lon:CLLocationDegrees,regi: CLCircularRegion,distance:CLLocationDistance,identifier:String){
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            var region = regi
            region = CLCircularRegion.init(center: coordinate, radius: 50, identifier: identifier)
            // nearbyDictionary 內的定位開始 Monitoring
            
            startRegionMonitoring(region: region)
            
            // 超過 1000 則停止 Monitoring
            if distance > 1000 {
                
                stopRegionMonitoring(region: region)
                
            }
        }
    }
    
    public func distance(lat:CLLocationDegrees,lon:CLLocationDegrees,userLocation:CLLocation) -> CLLocationDistance {
        let pins = CLLocation.init(latitude: lat, longitude: lon)
        let distance = pins.distance(from: userLocation) * 1.09361
        return distance
    }
    
    
}

