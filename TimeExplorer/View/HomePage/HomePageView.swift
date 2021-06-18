//
//  HomePageView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 27/05/2021.
//

import SwiftUI

struct HomePageView: View {

    @EnvironmentObject var mainStates:AppStates
    @Namespace var animation
    @State var chosenSection:String = ""
    @State var showSection:Bool = false
    @State var showArt:Bool = false
    @State var posts:[AVSData] = []
    
    func header(dim:CGSize) -> some View{
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10, content: {
                    MainText(content: "Hi,", fontSize: 30, color: .white, fontWeight: .semibold, style: .normal)
                    MainText(content: "Krishna", fontSize: 45, color: .white, fontWeight: .semibold, style: .normal)
                })
                Spacer()
                ImageView(img: nil, width: totalWidth * 0.2, height: totalWidth * 0.2, contentMode: .fill, alignment: .center)
                    .clipShape(Circle())
            }.padding().frame(width: dim.width, height: dim.height * 0.75, alignment: .center)
    }
    
    func topPostAction(){
        withAnimation(.hero) {
            self.showArt = true
        }
        
    }
    
    func parsePosts(posts: [PostData]){
        DispatchQueue.main.async {
            self.posts = posts.compactMap({!($0.isVideo ?? false) ? AVSData(img: $0.image?.first, title: $0.caption, subtitle: $0.user, data: $0) : nil})
        }
    }
    
    
    func subView(title:String) -> some View{
        var view = AnyView(Color.clear.frame(width: 0, height: 0, alignment: .center))
        let posts = self.posts.count > 20 ? Array(self.posts[0...20]) : self.posts
        switch (title) {
//            case "Trending Art": view = AnyView(TopArtScroll(data: posts))
            case "Trending Art": view = AnyView(AVScrollView(attractions: self.mainStates.PAPI.posts.compactMap({!($0.isVideo ?? false) ? AVSData(img: $0.image?.first, title: $0.caption, subtitle: $0.user, data: $0) : nil})))
            case "Featured Art": view = AnyView(FeaturedArt(art: test))
            case "Genres" : view = AnyView(AllArtView())
            case "Recent" : view = AnyView(PinterestScroll(data: self.posts))
            case "Recommended" : view = AnyView(RecommendArt(data: Array(repeating: asm, count: 10)))
            default: break;
        }
        
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: title, fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
                .padding(.horizontal)
            view
        }
        
    }
    
    
    var mainBody:some View{
        VStack(alignment: .leading, spacing: 15){
            self.subView(title: "Featured Art")
//            if !self.posts.isEmpty{
            self.subView(title: "Recommended")
//            }
            self.subView(title: "Trending Art")
            self.subView(title: "Genres")
//            if !self.posts.isEmpty{
            self.subView(title: "Recent")
//            }
            
        }
    }
    
    var body: some View {
        GeometryReader{g in
            let local = g.frame(in: .local)
            let w = local.width
            let h = local.height
            ZStack(alignment: .center){
                ScrollView(.vertical, showsIndicators: false){
//                    LazyVStack{
                        self.header(dim: .init(width: w, height: h * 0.35))
                        self.mainBody
                        Spacer().frame(height: 200)
//                    }
                }
                if self.showArt{
                    Color.clear.overlay(
                        PVMain(cityName: "", showPost: .constant(false), tabstate: .constant(false), show: $showArt).matchedGeometryEffect(id: "postsViewMain", in: self.animation,properties: .position,anchor: .top)
                    ).transition(.modal)
                }
            }
            
            
        }.frame(width: totalWidth, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {self.mainStates.loading = false})
        .onReceive(self.mainStates.PAPI.$posts, perform: self.parsePosts(posts:))
//        .background(Color.white)
        .background(Color.primaryColor)
       
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
