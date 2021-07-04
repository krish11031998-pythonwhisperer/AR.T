//
//  UserData.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/16/20.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User:Codable,Loopable{
    @DocumentID var id:String?
    var firstName:String?
    var lastName:String?
    var username:String?
    var emailID:String?
    var photoURL:String?
    var friends:[String]?
    var followers:Int?
    var postsCount:Int?
    var following:Int?
    var posts:[String]?
    var fullName:String?{
        get{
            guard let f = self.firstName, let l = self.lastName else {return nil}
            return f + " " + l
        }
    }
    var userInfo:User?{
        get{
            guard let emailID = self.emailID , let user = UserAPI.Cache[emailID] else {return nil}
            return user
        }
    }
}

struct PostData:Codable,Loopable,Identifiable,Equatable,Hashable{
    @DocumentID var id:String?
    var image:[String]?
    var video:[String]?
    var caption:String
    var user:String?
    var date:Date?
    var likes:Int?
    var comments:[String]?
    var isVideo:Bool?
    
    func parseVisualData() -> TrendingCardData?{
        let data = self
        let res:TrendingCardData? = .init(image: data.image?.first, vid_url: data.video?.first, username: data.user, mainText: data.caption, type: .post,data:data,date:data.date ?? Date())
        return res
    }

}

struct BlogData:Codable,Loopable,Identifiable{
    @DocumentID var id:String?
    var image:[String]?
    var headline:String?
    var articleText:String?
    var summaryText:String?
    var user:String?
    var date:Date?
    var location:String?
    
    func parseToFancyCardData() -> FancyCardData{
        return .init(headline: self.headline ?? "", mainImg: self.image?.first, subheadline: self.user, rowInfo: nil, data: self)
    }
    
    func parseVisualData() -> TrendingCardData?{
        let data = self
        var res:TrendingCardData? = nil
        res = .init(image: data.image?.first, username: data.user, mainText: data.headline, type: .blog,data:data,date:data.date ?? Date())
        return res
    }
    

}


struct TourData:Codable,Loopable,Identifiable{
    @DocumentID var id:String?
    var mainImage:String?
    var mainTitle:String?
    var mainDescription:String?
    var user:String?
    var date:Date?
    var location:String?
    var landmarks:[LandMarkGuide]?
    
    func parseVisualData() -> TrendingCardData?{
        var data = self
        var res:TrendingCardData? = .init(image: data.mainImage, username: data.user, mainText: data.mainTitle, type: .tour,data:data,location:data.location,date:data.date ?? Date())
        return res
    }
}

struct LandMarkGuide:Codable,Loopable,Comparable{
    static func < (lhs: LandMarkGuide, rhs: LandMarkGuide) -> Bool {
        return lhs.title == rhs.title && lhs.description == rhs.description && lhs.image == rhs.image && lhs.type == rhs.type
    }
    
    static func == (lhs: LandMarkGuide, rhs: LandMarkGuide) -> Bool {
        return lhs.title == rhs.title && lhs.description == rhs.description && lhs.image == rhs.image && lhs.type == rhs.type
    }
    
    var image:String?
    var title:String?
    var description:String?
    var type:String?
    var chapters:LandMarkHistory?
    
    func parseToFancyCardData() -> FancyCardData{
        let data = self
        return .init(headline: data.title ?? "Title", mainImg: data.image, subheadline: "", rowInfo:["Duration":"2 hrs","Reviews":"4.0/5"] , data: data as Any)
    }
    
}

struct LandMarkHistory:Codable,Loopable{
    var History:LandMarkHistoryChapters?
}

struct LandMarkHistoryChapters:Codable,Loopable{
    var chapters:[HistoryChapters]?
}

struct HistoryChapters:Codable,Loopable{
    var title:String?
    var speechText:String?
    var image:String?
    var images:[String]?
    var fun_fact:String?
    
    func parseToFancyCardData(headline:String) -> FancyCardData{
        var data = self
        return .init(headline: headline, mainImg: data.image, subheadline: data.title, rowInfo: nil, data: data)
    }
}

struct FIRAnnotationData:Codable,Loopable{
    var x:Float?
    var y:Float?
    var z:Float?
    var heading:String?
    var detail:String?
    var name:String?
    var vid_url:String?
//    var coord:VectorData?
//    var info:AnnotationData?
//    var name:String?
}

struct ArtData:Codable,Hashable,Identifiable,Loopable{
    static func == (lhs: ArtData, rhs: ArtData) -> Bool {
        return lhs._id == rhs._id
    }
    
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(self._id)
    }
    @DocumentID var id:String?
    var date:Date
    var title:String
    var model_url:String?
    var introduction:String
    var infoSnippets:[String:String]?
    var painterName:String?
    var painterImg:String?
    var top_facts:[String:String]?
    var thumbnail:String?
    var annotations:[FIRAnnotationData]?
    var main_vid_url:String?
//    var data:Any?
    
    func parseVisualData() -> TrendingCardData?{
        let data = self
        let res:TrendingCardData? = .init(image: data.thumbnail, vid_url:main_vid_url, mainText: data.title, type: .art, data: data,date: data.date)
        return res
    }
    
}

var blogExample = BlogData(image: ["https://firebasestorage.googleapis.com/v0/b/trippin-89b8b.appspot.com/o/blogImages%2F9FEF7991-5ACB-4B2E-8DD3-C7248B191546.jpg?alt=media&token=01373f41-05a2-440f-bfab-3c5ab03b7e5d","https://firebasestorage.googleapis.com/v0/b/trippin-89b8b.appspot.com/o/blogImages%2F6BFAAAEF-2B46-4FA3-8388-F4AF98A4FEBD.jpg?alt=media&token=f6eb2895-4b19-4253-8477-e8204b68d9c3"], headline: "Test2", articleText: "Test2", summaryText: "Test2", user: "krish.Venkat", date: Date(), location: "Dubai")
