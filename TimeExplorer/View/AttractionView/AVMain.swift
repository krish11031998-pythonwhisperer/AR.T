//
//  AVMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/20/20.
//

import SwiftUI
import MapKit
struct AVMain: View {
    @StateObject var TAAPI:AttractionTAAPI = AttractionTAAPI(test: false, ext: "latlang", query: .init(latitude: 0.0, longitude: 0.0))
    @State var swiped:Int = 0
    @EnvironmentObject var mainStates:AppStates
    var coordinate:CLLocationCoordinate2D{
        return self.mainStates.coordinates
    }
    
    func getData(){
        var newQuery = AttractionQuery(latitude: Float(self.coordinate.latitude), longitude: Float(self.coordinate.longitude))
        self.TAAPI.query = newQuery
        self.TAAPI.getAttractions()
    }
    
    var data:[AMID]{
        get{
            guard let attr = self.TAAPI.PBResult as? [AMID] else {return []}
            return attr
        }
    }
    
    var mapData:AttractionModel?{
        get{
            return self.data.count > self.swiped ? self.data[self.swiped].attraction : attractionExample.first
        }
    }
    
    var v2:some View{
        ZStack(alignment:.bottomLeading){
//            BasicMap(attraction: self.mapData)
//            BlurView(style: .dark)
//            if self.coordinate != nil || self.mapData != nil{
            BMView(title: "\(self.mapData?.name ?? "no name")", coordinate: self.mapData?.coordinates ?? self.coordinate)
            if self.data.count > 0{
                AVCarousel(attractions: self.data, swiped: $swiped)
            }
//            }
            
            
        }.edgesIgnoringSafeArea(.all)
    }
    
   
    
    var body: some View{
        NavigationView{
            self.v2
                .navigationBarHidden(true)
                .onAppear(perform: {
                    if self.TAAPI.PBResult.isEmpty{
                        self.getData()
                    }else if self.mainStates.loading{
                        self.mainStates.loading = false
                    }
                }).onReceive(self.TAAPI.$PBResult, perform: { res in
                    self.mainStates.loading = false
                })
        }
        
    }
}

struct AVMain_Previews: PreviewProvider {
    @State static var loading:Bool = false
    static var previews: some View {
        AVMain()
    }
}
