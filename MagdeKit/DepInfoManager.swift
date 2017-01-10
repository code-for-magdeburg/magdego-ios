//
//  DepInfoManager.swift
//  MagdeGo
//
//  Created by Rosario Raulin on 10/05/15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

import CoreLocation

@objc public enum DepManagerError : Int {
    case noLocationService
    case networkError
    case parsingError
}

public class DepInfoManager : NSObject, CLLocationManagerDelegate {
    
    open var newInfoCallback : (NSArray) -> ()
    open var errorCallback : (DepManagerError) -> ()

    lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()

    public init(newInfoCallback:@escaping (NSArray) ->(), errorCallback : @escaping (DepManagerError) -> ()) {
        self.newInfoCallback = newInfoCallback
        self.errorCallback = errorCallback
    }
    
    open func requestDepartureTimes(forLocation : CLLocation? = nil) {
        if let location = forLocation {
            getDepartureTimes(forLocation: location)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    fileprivate func getDepartureTimes(forLocation : CLLocation) {
        let longitude = forLocation.coordinate.longitude
        let latitude = forLocation.coordinate.latitude
        let apiURLString = "http://api.magdego.de/departure-time/location/\(longitude)/\(latitude)"
        let apiURL = URL(string: apiURLString)
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: apiURL!, completionHandler: { (data, resp, error) in
            if error != nil {
                self.errorCallback(.networkError)
            } else {
                let depInfoOptional = DepartureInformation.new(from: data)
                if let depInfo = depInfoOptional {
                    self.newInfoCallback(depInfo as NSArray)
                } else {
                    self.errorCallback(.parsingError)
                }
            }
        })
        task.resume()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .denied:
            fallthrough
        case .restricted:
            errorCallback(.noLocationService)
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        getDepartureTimes(forLocation: locations.last!)
    }
    
    }
