//
//  ContentView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/18/20.
//

import SwiftUI
import Firebase
import MapKit
import Introspect


class AppStates:ObservableObject{
    @Published var coordinates:CLLocationCoordinate2D = .init()
    @Published var loading:Bool = true
    @Published var tab:String = "home"
    @Published var showTab:Bool = true
    @Published var userAcc:Account = .init()
    @Published var photosManager:PhotoImages = .init()
    @Published var CAAPI:CAAPI = .init()
    @Published var LS:LocationSearch = .init(place:"",test:true)
    @Published var AAPI:ArtAPI = .init()
    @Published var TabAPI:[String:CAAPI] = ["home":.init(),"blogs":.init(),"feed":.init(),"attractions":.init(),"profile":.init()]
    var imageQuality:JPEGQuality = .medium
    var testMode:Bool = false
    var uniqueTabs = ["attractions"]
    
    
    func toggleTab(){
        if self.showTab{
            self.showTab = false
        }else if !self.uniqueTabs.contains(tab){
            self.showTab = true
        }
    }
    
    
    func fetchArt(limit:Int? = nil,department:String? = nil,type:String? = nil, skip:Int? = nil){
        if let api = self.TabAPI[self.tab], api.artDatas.isEmpty{
            api.getBatchArt(limit: limit ?? 50, department: department, type: type, skip: skip)
        }else{
            self.TabAPI[self.tab] = .init(limit: limit, department: department, type: type, skip: skip)
        }
    }
    
    func getArt(limit:Int? = nil,department:String? = nil,type:String? = nil, skip:Int? = nil) -> [CAData]?{
        if let data = self.TabAPI[self.tab]?.artDatas, !data.isEmpty{
            return data
        }else{
            self.fetchArt(limit: limit, department: department, type: type, skip: skip)
            return nil
        }
    }
    
}

struct AppView: View {
    @EnvironmentObject var mainStates:AppStates
//
    @State var showLoginPage:Bool = false
    var locationManager:LocationManager = .init()
    var tab:String{
        get{
            return self.mainStates.tab
        }
    }
    
    func getActiveView(tab:String? = nil) -> AnyView{
        var view:AnyView = AnyView(HomePageView())
        switch(tab ?? self.tab){
        case "feed": view = AnyView(ExploreViewMain())
        case "post": view = AnyView(CameraView().onAppear {self.mainStates.toggleTab()}.onDisappear {self.mainStates.toggleTab()})
        case "blogs": view = AnyView(ArtStoreMain())
        case "attractions": view = AnyView(FancyScrollMain())
        case "profile": view = AnyView(PortfolioMainView())
        default:
            break
        }
        return view
    }
        
    var activeView: some View{
        self.getActiveView()
            .frame(width: totalWidth,height:totalHeight)
            .animation(.linear)
    }
    
    func onAppear(){
        self.mainStates.userAcc.autoLogIn(){success in
            self.showLoginPage = !success
        }
        self.locationManager.updateLocation()
    }
    
    func locationUpdate(update:Bool){
        if let coord = self.locationManager.location?.coordinate{
            self.mainStates.coordinates = coord
            self.mainStates.LS.getCityName(coordinates: coord)
            self.locationManager.locationUpdated = false
        }

    }
    
    var body: some View {
        ZStack(alignment: .bottom){
            Color.black
            if self.showLoginPage{
                LVLogin(){value in
                    self.showLoginPage = !value
                }
            }
            if !self.showLoginPage{
//                self.activeView
                self.getActiveView()
                    .frame(width: totalWidth,height:totalHeight)
                    .animation(.linear)
                if self.mainStates.showTab{
                    TabBarView()
                }
                
                if self.mainStates.loading{
                    LoadingView()
                }
            }
            
        }
        .frame(width: totalWidth,height:totalHeight)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onChange(of: self.locationManager.locationUpdated, perform: self.locationUpdate(update:))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
