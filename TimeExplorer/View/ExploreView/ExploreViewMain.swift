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
//    var tabs:[String] = ["Blogs","Tours","Posts"]
//    var tabImages:[String:String] = ["Blogs": "blogs_image","Tours":"tours_image","Posts":"posts_image"]
//    var tabDescription: [String:String] = [:]
//    @State var selectedTab:String = "tours"
    @State var showPost:Bool = false
    @State var showBlog:Bool = false
    @State var showTour:Bool = false
    @State var show:Bool = true
    @EnvironmentObject var mainStates:AppStates
    
    @State var loadBlogs:Bool = false
    @State var loadPosts:Bool = false
    @State var loadTours:Bool = false
    
//    func tabCard(tab:String) -> some View{
//        let img = UIImage(named: self.tabImages[tab] ?? "") ?? .stockImage
//        let  image = Image(uiImage: img).resizable().aspectRatio(contentMode: .fill)
//        return GeometryReader{g in
//            let width:CGFloat = g.frame(in: .local).width
//            let height:CGFloat = g.frame(in: .local).height
//            HStack{
//                VStack{
//                    Spacer()
//                    MainText(content: tab, fontSize: 25, color: .white, fontWeight: .bold, style: .normal)
//                    MainText(content: self.tabDescription[tab] ?? "", fontSize: 15, color: .white, fontWeight: .regular, style: .normal)
//                }.padding().frame(width: width * 0.6, height: height, alignment: .leading).background(image.overlay(BlurView(style: .systemThinMaterialDark)))
//                image
//                    .frame(width: width * 0.4, height: height, alignment: .center)
//                    .clipped()
//
//            }.padding().frame(width: width,height:height)
//
//            .clipShape(ArcCorners(corner: .bottomRight, curveFactor: 0.075, cornerRadius: 30, roundedCorner: .allCorners))
//
//        }
//
//    }
    
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
    
//    var tabPicker:some View{
//        let tabs:[String] = ["recent","trending"]
//        return Picker("", selection: $selectedTab) {
//            ForEach(tabs,id:\.self){tab in
//                let selected = selectedTab == tab
//                MainText(content: tab.capitalized, fontSize: 12, color: .black, fontWeight: selected ? .semibold : .regular, style: .normal)
//            }
//        }.pickerStyle(SegmentedPickerStyle()).padding().frame(width:AppWidth,height: totalHeight * 0.075)
//    }
    
    func recentTabView(width:CGFloat, height:CGFloat) -> some View{
        
        let view =  TrendingMainView(tab:.constant(""),tabstate: self.$loadTours, showTrending: Binding.constant(false),types: ["tours","paintings"])
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
