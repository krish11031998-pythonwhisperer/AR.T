//
//  FancyScrollMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/05/2021.
//

import SwiftUI

struct FancyScrollMain: View {
    @EnvironmentObject var mainStates:AppStates
    @State var exploreList : [ExploreData] = []
    @State var art:ArtData? = nil
    @State var showArt:Bool = false
    var dispatchGroup:DispatchGroup = .init()
    
    func onAppear(){
        self.mainStates.toggleTab()
        if self.exploreList.isEmpty{
            print("calling on Appear")
            self.getTrendingItems()
            dispatchGroup.notify(queue: .main) {
                if self.mainStates.loading{
                    self.mainStates.loading = false
                }
            }
        }
        
    }
    
    func getTrendingItems(){
        print("Get trending Items is being called ! : \(self.exploreList.count)")
        dispatchGroup.enter()
        var res:[TrendingCardData] = []
        for collection in ["posts","blogs"]{
            FirebaseAPI.firebase_shared.getTopItems(limit: -1, collectionName: collection) { (qs, err) in
                guard let qs = qs else {return}
                switch(collection){
                case "posts":
                    if let posts = PostAPI.shared.parseQueryDocuments(q: qs)?.compactMap({ExploreData(img:$0.image?.first,data: $0 as Any)}){
                        DispatchQueue.main.async {
                            posts.forEach { (data) in
                                if !self.exploreList.contains(where: {$0.img == data.img}){
                                    self.exploreList.append(data)
                                }
                            }
//                            print("posts:  ",self.exploreList[0...2])
                        }
                    }
                case "blogs":
                    if let blogs = BlogAPI.shared.parseQueryDocuments(q: qs)?.compactMap({ExploreData(img:$0.image?.first,data: $0 as Any)}){

                        DispatchQueue.main.async {
                            blogs.forEach { (data) in
                                if !self.exploreList.contains(where: {$0.img == data.img}){
                                    self.exploreList.append(data)
                                }
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
        dispatchGroup.leave()
    }
    
    func updateShowArt(art: ArtData?){
        if art != nil{
            self.showArt = true
        }else if self.showArt{
            self.showArt = false
        }
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10){
            MainText(content: "Discover", fontSize: 30, color: .white, fontWeight: .bold, style: .heading)
            Spacer()
            SystemButton(b_name: "homekit", b_content: "",color: .white, size: .init(width: 20, height: 20)) {
                self.mainStates.tab = "home"
            }
        }.padding()
        .padding(.top,35)
        .frame(width: totalWidth, alignment: .leading)
        .background(bottomShadow.rotationEffect(.init(degrees: .init(180))))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
            FancyScroll(selectedArt: $art,showArt:$showArt,data: self.exploreList)
            self.header
            if self.showArt{
                ArtScrollMainView(data: test, showArt: $showArt)
                    .transition(.move(edge: .bottom).combined(with: .identity))
            }
        }.edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onChange(of: self.art, perform: self.updateShowArt(art:))
        .onDisappear(perform: self.mainStates.toggleTab)
        .animation(.easeInOut)

    }
}

struct FancyScrollMain_Previews: PreviewProvider {
    static var previews: some View {
        FancyScrollMain()
    }
}
