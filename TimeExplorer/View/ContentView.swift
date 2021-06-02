//
//  ContentView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/18/20.
//

import SwiftUI
import Firebase
import MapKit

class AppStates:ObservableObject{
    @Published var coordinates:CLLocationCoordinate2D = .init()
    @Published var loading:Bool = true
    @Published var tab:String = "blogs"
    @Published var showTab:Bool = true
    @Published var userAcc:Account = .init()
    @Published var photosManager:PhotoImages = .init()
    @Published var LS:LocationSearch = .init(place:"",test:true)
    @Published var IPAPI:InstagramAPI = .init(tag: "")
    @Published var PAPI:PostAPI = .init()
    @Published var ToAPI:TourAPI = .init()
    @Published var AAPI:ArtAPI = .init()
    
    var uniqueTabs = ["attractions"]
    
    
    func toggleTab(){
        if self.showTab{
            self.showTab = false
        }else if !self.uniqueTabs.contains(tab){
            self.showTab = true
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
    
    var _activeView:AnyView{
//        var view:AnyView = AnyView(AMMain())
        var view:AnyView = AnyView(HomePageView())
        switch(self.tab){
            case "feed": view = AnyView(ExploreViewMain())
            case "post": view = AnyView(CameraView().onAppear {self.mainStates.toggleTab()}.onDisappear {self.mainStates.toggleTab()})
            case "blogs": view = AnyView(ArtStoreMain())
            case "attractions": view = AnyView(FancyScrollMain())
            case "profile": view = AnyView(UVMain().frame(height:totalHeight))
            default:
                break
        }
        return view
    }
    
    var activeView: some View{
            VStack{
                self._activeView
            }.frame(width: totalWidth,height:totalHeight).animation(.default)
            .background(Color.mainBG)
    }
    
    var body: some View {
        NavigationView{
            ZStack(alignment: .bottom){
                Color.black
                if self.showLoginPage{
                    LVLogin(){value in
                        self.showLoginPage = !value
                    }
                }
                if !self.showLoginPage{
                    self.activeView
                    if self.mainStates.showTab{
                        TabBarView()
                    }
                    
                    if self.mainStates.loading{
                        LoadingView()
                    }
                }
                
            }.edgesIgnoringSafeArea(.all)

            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }.frame(width: totalWidth,height:totalHeight).edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            self.mainStates.userAcc.autoLogIn(){success in
                self.showLoginPage = !success
                if success{
                    self.mainStates.PAPI.getTopPosts(limit: 10)
                }
            }
            self.locationManager.updateLocation()
        })
        .onChange(of: self.locationManager.locationUpdated, perform: { value in
            if let coord = self.locationManager.location?.coordinate{
                self.mainStates.coordinates = coord
                self.mainStates.LS.getCityName(coordinates: coord)
                self.mainStates.PAPI.getTopPosts(limit: 10)
                self.locationManager.locationUpdated = false
            }
            
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
