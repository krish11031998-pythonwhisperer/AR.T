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
    var dispatchGroup:DispatchGroup = .init()
    
    func onAppear(){
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
                            print("posts:  ",self.exploreList[0...2])
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

    var body: some View {
        ZStack(alignment: .center) {
            FancyScroll(data: self.exploreList)
        }.onAppear(perform: self.onAppear)
    }
}

struct FancyScrollMain_Previews: PreviewProvider {
    static var previews: some View {
        FancyScrollMain()
    }
}
