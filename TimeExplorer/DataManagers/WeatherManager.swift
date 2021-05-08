//
//  WeatherManager.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/4/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import Foundation
import MapKit

var DataCache = NSCache<NSString,NSData>()
class WeatherAPI:ObservableObject{
    
    static var imageUrl:String = "https://openweathermap.org/img/wn/"
    var uri:String = "https://api.openweathermap.org/data/2.5/onecall?"
    var appID:String = "7b509e5e1d1e7ff010a0476dae3589ad"
    var coordinate:CLLocationCoordinate2D = .init(latitude: 25.2048, longitude: 55.2708)
    @Published var result:WeatherData? = nil;
    
    init(coordinates:CLLocationCoordinate2D?=nil){
        if let coor = coordinates{
            self.coordinate = coor
        }
        
    }
    
    func getWeatherInfo(handler: @escaping (() ->  Void)){
        var finalURL = "\(self.uri)APPID=\(self.appID)&lat=\(self.coordinate.latitude)&lon=\(self.coordinate.longitude)"
        if let cachedData = DataCache.object(forKey: finalURL as NSString), let safeParsedData = self.parseData(cachedData as! Data){
            DispatchQueue.main.async {
                self.result = safeParsedData
                print("cached Data restored and read")
                handler()
            }
        }else if let url = URL(string: finalURL){
            URLSession.shared.dataTask(with: url) { (data, resp, err) in
                guard let safeData = data else{
                    if let err = err{
                        print("There was an error \(err)");
                    }
                    return
                }
                DataCache.setObject(safeData as NSData, forKey: finalURL as NSString)
                if let safeParsedData = self.parseData(safeData){
                    DispatchQueue.main.async {
                        self.result = safeParsedData
                        print("data read and parsed!")
                        handler()
                    }
                }
            }.resume()
        }
        
    }
    
    
    
    func parseData(_ data:Data) -> WeatherData?{
        var decoder = JSONDecoder()
        do{
            var result = try decoder.decode(WeatherData.self, from: data)
            return result
        }catch{
            print("There was an error \(error)")
        }
        return nil
        
    }
    
    static func getWeatherIcons(_ name:String) -> UIImage{
        var fullURL = "\(WeatherAPI.imageUrl)\(name)@2x.png"
        return UIImage.downloadImage(fullURL)
    }
    
    
    
}
