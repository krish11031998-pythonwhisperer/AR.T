//
//  TripAdvisorAPI.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/8/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

var TripAdvisorCache:NSCache<NSString,NSData> = .init()

import Foundation
import MapKit

class TripAdvisorAPI{
    var headers:[String:String] = [
        "x-rapidapi-host": "tripadvisor1.p.rapidapi.com",
        "x-rapidapi-key": "75735682fbmshb422537a62478ffp113a18jsndfd953c8e14c"
    ]
    var url:String = ""
    init(url:String){
        self.url = url
    }
    
    func getData(handler: @escaping (Data?,URLResponse?,Error?) -> Void){
        if let data = TripAdvisorCache.object(forKey: self.url as NSString){
            print("Reading Cached Data!")
            //            DispatchQueue.main.async {
            handler(data as Data,nil,nil)
            //            }
            
        }else{
            guard let url = URL(string: self.url) else {return}
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.allHTTPHeaderFields = self.headers
            URLSession.shared.dataTask(with: urlRequest, completionHandler: handler).resume()
        }
        
    }
}


class AttractionTAAPI:TripAdvisorAPI,ObservableObject{
    
    var test:Bool = false
    var ext:String = ""
    var query:AttractionQuery
    @Published var PBResult:[Any] = []
    init(test:Bool,ext:String,query:AttractionQuery){
        self.test = test
        self.query = query
        super.init(url: AttractionQuery.uri)
        self.ext = self.extensionURL(ext: ext)
    }
    
    func extensionURL(ext:String) -> String{
        var result:String = ""
        switch(ext){
        case "list":
            result = "list?"
            break;
        case "latlang":
            result = "list-by-latlng?"
            break;
        case "details":
            result = "get-details?"
            break;
        default:
            result = "list?"
        }
        return result
    }
    
    func parseRequest() -> String?{
        var result:String?
        //        if let safeQuery = self.query as? AttractionQuery,!test{
        if !test{
            do{
                let parsedquery:[String:String] = try self.query.allKeysValues(obj: nil).compactMapValues({ $0 as? String })
                result = AttractionQuery.uri + self.ext
                var temps = Array(parsedquery.keys).map { (key) -> String in
                    return "\(key)=\(parsedquery[key] ?? "")"
                }.reduce("") { (x, y) -> String in
                    return x+"&"+y
                }
                result? += temps
            }catch{
                print("There was an error, \(error)")
                return nil
            }
        }
        return result
    }
    
    func parseData(data:Data) -> Any?{
        var result:Any? = nil
        var decoder = JSONDecoder()
        do{
            result = try decoder.decode(ATAR.self, from: data)
        }catch{
            print("Error while parsing! \(error)")
        }
        
        return result
    }
    
    func getAttractions(){
        guard let parameters = self.parseRequest(), let url = URL(string: parameters) else {return}
        self.url = url.absoluteString + "&limit=50&distance=25"
        self.getData { (data, resp, err) in
            guard let safeData = data else {
                DispatchQueue.main.async {
                    self.PBResult = attractionExampleTwo
                }
                return}
            if TripAdvisorCache.object(forKey: self.url as NSString) == nil{
                TripAdvisorCache.setObject(safeData as NSData, forKey: self.url as NSString)
            }
            print("Data Cached")
            if let SPD = self.parseData(data: safeData) as? ATAR{
                DispatchQueue.main.async {
                    var data = SPD.data
                    data = data.filter({ (attr) -> Bool in
                        var res = false
                        if attr.photo != nil &&  attr.name != nil && attr.location_string != nil{
                            res = true
                        }
                        return res
                    })
                    self.PBResult = data.enumerated().map({AMID(id: $0.offset, attraction: $0.element)})
                    print("data: \(Array(self.PBResult[0...2]))")
                }
            }else{
                DispatchQueue.main.async {
                    self.PBResult = attractionExampleTwo
                }
                
            }
        }
    }
    
}


class LocationSearch:TripAdvisorAPI,ObservableObject{
    @Published var result:[LocationSearchData] = []
//    @Published var city: AttractionModel = .init()
//    @Published var attractions:[AMID] = []
    var place:String = ""
    var test:Bool
    init(place:String,test:Bool = false){
        self.place = place
        self.test = test
        super.init(url: LocationSearchData.uri+"query=\(place.lowercased())")
    }
    
    func getCityName(coordinates:CLLocationCoordinate2D){
        coordinates.getPlacemark { (placemark) in
            if let safePM = placemark{
                var city = safePM.locality ?? "gmt"
                self.getLocationSearch(city)
            }
        }
    }
    
    func getLocationSearch(_ city:String){
        if self.place != city && city != ""{
            self.place = city
//            self.getLocation {
//                print("Got Data")
//            }
        }
    }
    
    func parseData(data:Data) -> [LocationSearchData]?{
        var result:LSR? = nil
        let decoder = JSONDecoder()
        do{
            result = try decoder.decode(LSR.self, from: data)
        }catch{
            print("There was an error while parsing the data: \(error)")
        }
        return result?.data
        
    }
    
    func getLocation(handler:@escaping () -> Void){
        self.url = LocationSearchData.uri+"query=\(place.lowercased())"
        
        if test{
            DispatchQueue.main.async {
                self.result = [LSRExample]
                handler()
                
            }
            return
        }else{
            self.getData { (data, resp, err) in
                if let safeData = data,let SPD = self.parseData(data: safeData){
                    if TripAdvisorCache.object(forKey: self.url as NSString) == nil{
                        TripAdvisorCache.setObject(safeData as NSData, forKey: self.url as NSString)
                    }
                    DispatchQueue.main.async {
                        self.result = SPD
//                        self.attractions = LocationSearchData.parseLSD_to_AMID(SPD)
//                        self.city = LocationSearchData.extractCityInfo(SPD)
                        if let res = TripAdvisorCache.object(forKey: self.url as NSString), let resData = self.parseData(data: res as Data){
                            print(resData.first ?? .init(result_type: "No Result"))
                        }
                        handler()
                    }
                }
            }
            
        }
    }
    
}


class PhotoReviewSearch:TripAdvisorAPI,ObservableObject{
    static var uri:String = "https://tripadvisor1.p.rapidapi.com/photos/list?limit=50&location_id="
    @Published var result:[AMID] = []
    var test:Bool = false
    var location_id:String
    init(location:String,test:Bool = false){
        self.location_id = location
        super.init(url: PhotoReviewSearch.uri+self.location_id)
    }
    
    func parseData(data: Data) -> ATAR?{
        var result:ATAR? = nil
        var decoder = JSONDecoder()
        do{
            result = try decoder.decode(ATAR.self, from: data)
        }catch{
            print("There was an error : \(error)")
        }
        return result
    }
    
    func getReviews(handler:@escaping (() -> Void)){
        self.url = PhotoReviewSearch.uri+self.location_id
        self.getData { (data, resp, err) in
            if let safeData = data , let SPD = self.parseData(data:safeData){
                if TripAdvisorCache.object(forKey: self.url as NSString) == nil{
                    TripAdvisorCache.setObject(safeData as NSData, forKey: self.url as NSString)
                }
                
                DispatchQueue.main.async {
                    var count = 0
                    var data = SPD.data
                    data = data.filter({ (attr) -> Bool in
                        var res = false
                        if attr.images != nil, attr.linked_reviews != nil &&  attr.user != nil{
                            res = true
                        }
                        return res
                    })
                    self.result = data.map({ (attr) -> AMID in
                        
                        var res = AMID(id: count, attraction: attr)
                        count += 1
                        return res
                    })
                    print("data: \(Array(self.result[0...6]))")
                    handler()
                    
                }
                
            }
        }
    }
}
