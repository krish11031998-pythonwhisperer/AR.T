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
import SUI


class AppStates:ObservableObject{
    @Published var loading:Bool = true
    @Published var tab:String = "home"
    @Published var showTab:Bool = true
    @Published var userAcc:Account = .init()
    @Published var CAAPI:ArtAPI = .init()
    @Published var AAPI:FirebaseArtAPI = .init()
    @Published var TabAPI:[String:ArtAPI] = ["home":.init(),"blogs":.init(),"feed":.init(),"attractions":.init(),"profile":.init()]
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
    @State var showLoginPage:Bool = false
    var tab:String{
        get{
            return self.mainStates.tab
        }
    }
	
	init() {
		UITabBar.appearance().isHidden = true
	}
 
	var tabView: some View {
		TabView(selection: $mainStates.tab) {
			HomePageView()
				.transparentNavBackground()
				.tag("home")
			SearchView()
				.transparentNavBackground()
				.tag("blogs")
			DiscoverView()
				.transparentNavBackground()
				.tag("attractions")
			PortfolioMainView()
				.transparentNavBackground()
				.tag("profile")
			ExploreViewMain()
				.transparentNavBackground()
				.tag("feed")
		}
		.fillFrame()
		
	}
            
    var body: some View {
		ZStack(alignment: .bottom){
			Color.black
			tabView
			if self.mainStates.showTab{
				TabBarView()
					.transitionFrom(.bottom)
			}
			
			if self.mainStates.loading{
				LoadingView()
			}

		}
//		.frame(width: totalWidth,height:totalHeight)
//		.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
