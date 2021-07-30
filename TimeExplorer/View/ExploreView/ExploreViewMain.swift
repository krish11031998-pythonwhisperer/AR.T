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
    @State var showPost:Bool = false
    @State var showBlog:Bool = false
    @State var showTour:Bool = false
    @State var show:Bool = true
    @EnvironmentObject var mainStates:AppStates
    
    @State var loadBlogs:Bool = false
    @State var loadPosts:Bool = false
    @State var loadTours:Bool = false
    
    func handleClick(tab:String){
        switch(tab){
            case "Posts":
                self.showPost = true
                break;
            case "Tours":
                self.showTour = true
                break;
            case "Blogs":
                self.showBlog = true
                break;
            default:
                break
        }
    }

    
    func recentTabView(width:CGFloat, height:CGFloat) -> some View{
        
        let view =  TrendingMainView(tab:.constant(""),tabstate: self.$loadTours, showTrending: Binding.constant(false))
                        .tag("tours")
        return view
    }
    
    var body: some View {
        GeometryReader{g in
            let width:CGFloat = g.frame(in: .local).width
            let height:CGFloat = g.frame(in: .local).height
            

            ZStack(alignment:.top){
                self.recentTabView(width: width, height: height)
            }.animation(.spring())
            .edgesIgnoringSafeArea(.all)
            .frame(width: width, height: height, alignment: .center)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .frame(width:totalWidth,height:totalHeight)
    }
}

struct ExploreViewMain_Previews: PreviewProvider {
    static var previews: some View {
        ExploreViewMain()
    }
}
