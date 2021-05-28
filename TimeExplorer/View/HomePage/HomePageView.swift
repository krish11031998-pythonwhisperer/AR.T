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
    
    func header(dim:CGSize) -> some View{
        ZStack(alignment: .center){
//            ImageView(img: .init(named: "user_bg"),width: dim.width,height: dim.height, contentMode: .fill, alignment: .bottom, testMode: true)
            StickyHeaderImage(w: dim.width, h: dim.height, image: .init(named: "user_bg"), curvedCorner: true)
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10, content: {
                    MainText(content: "Hi,", fontSize: 30, color: .white, fontWeight: .semibold, style: .normal)
                    MainText(content: "Krishna", fontSize: 45, color: .white, fontWeight: .semibold, style: .normal)
                })
                Spacer()
                ImageView(img: nil, width: totalWidth * 0.2, height: totalWidth * 0.2, contentMode: .fill, alignment: .center, testMode: false)
                    .clipShape(Circle())
            }.padding()
            
        }.frame(width: dim.width, height: dim.height, alignment: .center)
    }
    
    func topPostAction(){
        withAnimation(.hero) {
//            self.chosenSection = "posts"
            self.showArt = true
        }
        
    }
    
    func subView(title:String) -> some View{
        var view = AnyView(Color.clear)
        switch (title) {
        case "Trending Art": view = AnyView(AVScrollView(attractions: Array.init(repeating: asm, count: 10)))
        case "Featured Art": view = AnyView(FeaturedArt(art: test))
//        case "Recent" : view = AnyView(TopPostView (animation: self.animation, self.topPostAction).padding(.top,50).frame(width: totalWidth, alignment: .center))
        case "Recent" : view = AnyView(TopArtScroll(data: Array.init(repeating: asm, count: 10)))
        default:
            break
        }
        
        return VStack(alignment: .leading, spacing: 5){
            MainText(content: title, fontSize: 30, color: .black, fontWeight: .bold, style: .normal)
                .padding()
            view
        }
        
    }
    
    
    var mainBody:some View{
        VStack(alignment: .leading, spacing: 10){
            self.subView(title: "Featured Art")
            self.subView(title: "Trending Art")
            self.subView(title: "Recent")
//            self.subView(title: "Recent")
        }
    }
    
    var body: some View {
        GeometryReader{g in
            let local = g.frame(in: .local)
            let w = local.width
            let h = local.height
            ZStack(alignment: .center){
                ScrollView(.vertical, showsIndicators: false){
                    self.header(dim: .init(width: w, height: h * 0.35))
                    self.mainBody
                   
                    Spacer().frame(height: 200)
                }
                if self.showArt{
                    Color.clear.overlay(
                        PVMain(cityName: "", showPost: .constant(false), tabstate: .constant(false), show: $showArt).matchedGeometryEffect(id: "postsViewMain", in: self.animation,properties: .position,anchor: .top)
                    ).transition(.modal)
                }
            }
            
            
        }.frame(width: totalWidth, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            self.mainStates.loading = false
        })
        .onChange(of: self.showArt, perform: { value in
            print("Art Value : ",value)
        })
        .background(Color.white)
       
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
