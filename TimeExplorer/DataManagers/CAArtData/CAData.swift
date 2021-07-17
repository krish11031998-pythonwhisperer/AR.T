//
//  CAData.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 27/06/2021.
//

import Foundation

class CAResultBatch:Codable{
    var data:[CAData]?
}

class CAResultSingle:Codable{
    var data:CAData?
}

class CAArtDim:Codable{
    var width:Float?
    var height:Float?
}

class CADim:Codable{
    var framed:CAArtDim?
    var unframed:CAArtDim?
}

class CAData:Codable{
    var id:Int?
    var accession_number:String?
    var share_license_status:String?
    var tombstone:String?
    var title:String?
    var title_in_original_language:String?
    var series:String?
    var series_in_original_language:String?
    var creation_date:String?
    var creation_date_earliest:Int?
    var creation_date_latest:Int?
    var creators:[CACreators]?
    var culture:[String]?
    var technique:String?
    var department:String?
    var collection:String?
    var type:String?
    var measurements:String?
    var dimensions:CADim?
    var images:CAImages?
    var wall_description:String?
    var url:String?
    var fun_fact:String?
    
    
    var artistName:String?{
        guard let artist_name = self.creators?.first?.description else {return nil}
        let name_split = artist_name.split(separator: "(").first ?? "No Name"
        
//        return name_split.count > 2 ? Array(name_split[0...2]).joined(separator: " ") : name_split.joined(separator: " ")
        return String(name_split).stripSpaces()
    }
    
    var thumbnail:String?{
        return self.images?.web?.url
    }
    
    var original:String?{
        return self.images?.print?.url
    }
    
    
    var PaintingInfo:[String:String]?{
        let data = self
        var details:[String:String] = [:]
        
        if let department = data.department{
            details["Department"] = department
        }
        
        if let culture = data.culture?.first{
            details["Culture"] = culture
        }
        
        
        if let technique = data.technique{
            details["Technique"] = technique.capitalized
        }
            
        if let dim = data.dimensions{
            if let framed = dim.framed{
                details["Framed"] = "\(framed.height ?? 0)m x \(framed.width ?? 0)m"
            }
            
//            if let unframed = dim.unframed{
//                details["unframed"] = "\(unframed.height ?? 0)m x \(unframed.width ?? 0)m"
//            }
        }
        
        return details.keys.count == 0 ? nil : details
}

    func parseAVSData() -> AVSData?{
        guard let img = self.thumbnail, let title = self.title, let subtitle = self.artistName else {return nil}
        return AVSData(img: img, title: title, subtitle: subtitle, data: self)
    }
}


class CACreators:Codable{
    var id:Int?
    var description:String?
    var role:String?
    var biography:String?
    var name_in_original_language:String?
    var birth_year:String?
    var death_year:String?
}


class CAImages:Codable{
    var web:CAImage?
    var print:CAImage?
    var full:CAImage?
}

class CAImage:Codable{
    var url:String?
    var width:String?
    var height:String?
}

