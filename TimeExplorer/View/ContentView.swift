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
    @Published var tab:String = "feed"
    @Published var showTab:Bool = true
    @Published var userAcc:Account = .init()
    @Published var photosManager:PhotoImages = .init()
    @Published var LS:LocationSearch = .init(place:"",test:true)
    @Published var IPAPI:InstagramAPI = .init(tag: "")
    @Published var PAPI:PostAPI = .init()
    @Published var ToAPI:TourAPI = .init()
    @Published var AAPI:ArtAPI = .init()
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
    
    var activeView: some View{
            VStack{
                if self.tab == "home"{
                    AMMain()
                }
                if self.tab == "feed"{
                    ExploreViewMain()
                }
                if self.tab == "post"{
                    CameraView()
                        .onAppear {
                            if self.mainStates.showTab{
                                self.mainStates.showTab = false
                            }
                        }.onDisappear {
                            if !self.mainStates.showTab{
                                self.mainStates.showTab = true
                            }
                        }
                }
                if self.tab == "blogs"{
                    BVMain()
                }
                if self.tab == "attractions"{
//                    AVMain().frame(height:totalHeight)
                    ExploreTabView()
                }
                if self.tab == "profile"{
                    UVMain().frame(height:totalHeight)
                }
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
            self.mainStates.userAcc.autoLogIn(){value in
                self.showLoginPage = !value
            }
            self.locationManager.updateLocation()
        })
        .onChange(of: self.locationManager.locationUpdated, perform: { value in
            if let coord = self.locationManager.location?.coordinate{
                self.mainStates.coordinates = coord
                self.mainStates.LS.getCityName(coordinates: coord)
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
