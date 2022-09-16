//
//  ExploreViewMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 02/01/2021.
//

import SwiftUI

class TabLoadState:ObservableObject{
    @Published var loadBlogs:Bool = false
    @Published var loadPosts:Bool = false
    @Published var loadTours:Bool = false
}


struct ExploreViewMain: View {
    @State var show:Bool = true
    @EnvironmentObject var mainStates:AppStates
	
	var body: some View {
		TrendingMainView()
			.frame(width: .totalWidth, height: .totalHeight)
			.edgesIgnoringSafeArea(.all)
			.navigationBarHidden(true)
	}
}

struct ExploreViewMain_Previews: PreviewProvider {
    static var previews: some View {
        ExploreViewMain()
    }
}
