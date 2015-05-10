//
//  DepInfoManager.swift
//  MagdeGo
//
//  Created by Rosario Raulin on 10/05/15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

import CoreLocation

public class DepInfoManager : NSObject, CLLocationManagerDelegate {
    
    public var newInfoCallback : (NSArray) -> ()
    public var errorCallback : (String) -> ()
    
    lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
    public init(newInfoCallback:(NSArray) ->(), errorCallback : (String) -> () = { println($0) }) {
        self.newInfoCallback = newInfoCallback
        self.errorCallback = errorCallback
    }
    
    public func requestDepartureTimes(forLocation : CLLocation? = nil) {
        if var location = forLocation {
            getDepartureTimes(location)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func getDepartureTimes(forLocation : CLLocation) {
        let longitude = forLocation.coordinate.longitude
        let latitude = forLocation.coordinate.latitude
        let apiURLString = "http://api.magdego.de/departure-time/location/\(longitude)/\(latitude)"
        let apiURL = NSURL(string: apiURLString)
        let urlSession = NSURLSession.sharedSession()
        
        let task = urlSession.dataTaskWithURL(apiURL!, completionHandler: { (data, resp, error) in
            if error != nil {
                self.errorCallback("Error fetching new dep data")
            } else {
                let depInfoOptional = DepartureInformation.newFromData(data)
                if let depInfo = depInfoOptional {
                    self.newInfoCallback(depInfo)
                } else {
                    self.errorCallback("Error parsing API result")
                }
            }
        })
        task.resume()
    }
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Denied:
            fallthrough
        case .Restricted:
            errorCallback("Location usage denied")
        case .NotDetermined:
            errorCallback("Location status not determined yet")
        default:
            break
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        getDepartureTimes(locations.last as! CLLocation)
    }
}