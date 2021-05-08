//
//  LocationManager.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 04/12/2020.
//

import Foundation
import SwiftUI
import MapKit

class LocationManager: NSObject,ObservableObject{
    var manager = CLLocationManager()
    @Published var location:CLLocation? = nil
    @Published var locationUpdated:Bool = false
    
    override init() {
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.distanceFilter = kCLDistanceFilterNone
        self.manager.requestWhenInUseAuthorization()
    }
    
    func updateLocation(){
        self.manager.startUpdatingLocation()
    }
}

extension LocationManager:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else {return}
        if CLLocationCoordinate2D.hasChanged(latestLocation.coordinate, self.location?.coordinate ?? .init()){
            self.location = latestLocation
            self.locationUpdated = true
        }
    }
}
