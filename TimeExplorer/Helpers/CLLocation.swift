//
//  CLLocation.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/26/20.
//

import SwiftUI
import UIKit
import CoreLocation
//import PlaygroundSupport
//PlaygroundPage.current.needsIndefiniteExecution = true

extension CLLocationCoordinate2D{
    func getPlacemark(handler:@escaping (_ placemark:CLPlacemark?) -> Void){
        var coords = self
        var location:CLLocation = .init(latitude: coords.latitude, longitude: coords.longitude)
        let geocoder = CLGeocoder()
        var finalplacemark:CLPlacemark? = nil
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                handler(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                handler(nil)
                return
            }
            
            handler(placemark)
        }
    }
    
    func latlon() -> CLLocationDegrees{
        return self.latitude + self.longitude
    }
    
    
    static func hasChanged(_ a:CLLocationCoordinate2D, _ b:CLLocationCoordinate2D) -> Bool{
        func absDiff(x:Float,y:Float) -> Float{
            return x >= y ? x - y : y - x
        }
        var lat = absDiff(x: Float(a.latitude), y: Float(b.latitude)) > 1
        var lon = absDiff(x: Float(a.longitude), y: Float(b.longitude)) > 1
        return lat && lon
    }
}

