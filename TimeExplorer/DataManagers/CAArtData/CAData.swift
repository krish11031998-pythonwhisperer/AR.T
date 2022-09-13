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
    let id:Int?
    let accession_number:String?
    let share_license_status:String?
    let tombstone:String?
    let title:String?
    let title_in_original_language:String?
    let series:String?
    let series_in_original_language:String?
    let creation_date:String?
    let creation_date_earliest:Int?
    let creation_date_latest:Int?
    let creators:[CACreators]?
    let culture:[String]?
    let technique:String?
    let department:String?
    let collection:String?
    let type:String?
    let measurements:String?
    let dimensions:CADim?
    let images:CAImages?
    let wall_description:String?
	let digital_description: String?
    let url:String?
    let fun_fact:String?
    
    
    var artistName:String?{
        guard let artist_name = self.creators?.first?.description else {return nil}
        let name_split = artist_name.split(separator: "(").first ?? "No Name"
        
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

