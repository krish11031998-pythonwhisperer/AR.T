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
    
    
    var artistName:String{
        return String(self.creators?.filter({$0.role != nil ? $0.role! == "artists" : false}).description.split(separator: "(").first ?? "No Name").stripSpaces()
    }
    
    var thumbnail:String{
        return self.images?.web?.url ?? ""
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

