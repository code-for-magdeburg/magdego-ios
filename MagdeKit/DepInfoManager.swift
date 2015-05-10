//
//  DepInfoManager.swift
//  MagdeGo
//
//  Created by Rosario Raulin on 10/05/15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

import CoreLocation

@objc public enum DepManagerError : Int {
    case NoLocationService
    case NetworkError
    case ParsingError
}

public class DepInfoManager : NSObject, CLLocationManagerDelegate {
    
    public var newInfoCallback : (NSArray) -> ()
    public var errorCallback : (DepManagerError) -> ()
    
    lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
    public init(newInfoCallback:(NSArray) ->(), errorCallback : (DepManagerError) -> () = { $0 }) {
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
                self.errorCallback(.NetworkError)
            } else {
                let depInfoOptional = DepartureInformation.newFromData(data)
                if let depInfo = depInfoOptional {
                    self.newInfoCallback(depInfo)
                } else {
                    self.errorCallback(.ParsingError)
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
            errorCallback(.NoLocationService)
        default:
            break
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        getDepartureTimes(locations.last as! CLLocation)
    }
}