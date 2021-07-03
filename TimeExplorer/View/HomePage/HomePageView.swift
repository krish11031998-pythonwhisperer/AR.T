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
        let posts = (self.mainStates.PAPI.posts.count > 10 ? Array(self.mainStates.PAPI.posts[0...9]) : self.mainStates.PAPI.posts).compactMap({!($0.isVideo ?? false) ? AVSData(img: $0.image?.first, title: $0.caption, subtitle: $0.user, data: $0) : nil})
        switch (title) {
        case "Trending Art": view = AnyView(TopArtScroll(data: posts))
            case "Featured Art": view = AnyView(FeaturedArt(art: test))
            case "Genres" : view = AnyView(AllArtView())
//            case "Recent" : view = AnyView(PinterestScroll(data: posts))
            case "Recent" : view = AnyView(RecentArtView(data: posts))
            case "Recommended", "Ones to Check Out" : view = AnyView(RecommendArt(data: Array(repeating: asm, count: 10)))
            case "Artists" : view = AnyView(ArtistView(data: Array(repeating: asm, count: 10)))
            default: break;
        }
        return Group{
                MainText(content: title, fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
                    .padding(.horizontal)
                    .frame(width: totalWidth, alignment: .leading)
                view
            }
        
    }
    
    
    
    var body: some View {
                ScrollView(.vertical, showsIndicators: false){
//                    LazyVStack{
                        self.header(dim: .init(width: totalWidth, height: totalHeight * 0.35))
                        self.subView(title: "Featured Art")
//                        self.subView(title: "Recommended")
                        self.subView(title: "Trending Art")
//                        self.subView(title: "Genres")
                        self.subView(title: "Recent")
                        self.subView(title: "Ones to Check Out")
                        self.subView(title: "Artists")
                        Spacer().frame(height: 200)
//                }
//                if self.showArt{
//                    Color.clear
//                    .overlay(
//                        PVMain(cityName: "", showPost: .constant(false), tabstate: .constant(false), show: $showArt).matchedGeometryEffect(id: "postsViewMain", in: self.animation,properties: .position,anchor: .top)
//                    )
//                    .transition(.modal)
//                }
//            }
                }
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {self.mainStates.loading = false})
        .onReceive(self.mainStates.PAPI.$posts, perform: self.parsePosts(posts:))
        .background(Color.primaryColor)
       
    }
}

extension HomePageView{
    
    func RecentArtView(data:[AVSData]) ->some View{
        let w = totalWidth * 0.5 - 10
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: w, maximum: w), spacing: 10, alignment: .center)], alignment: .center, spacing: 10) {
            ForEach(Array(data.enumerated()),id: \.offset) { _data in
                let d = _data.element
                ImageView(url: d.img, heading: d.title, width: w, height: totalHeight * 0.35, contentMode: .fill, alignment: .center, isPost: true, headingSize: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }.padding(.bottom)
    }
    
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
