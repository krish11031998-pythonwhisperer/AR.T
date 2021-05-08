//
//  ExploreTabView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 12/03/2021.
//

import SwiftUI

enum direction{
    case left
    case right
}

struct ExploreData{
    var img:String?
    var data:Any?
}

extension Array{
    func TwoDArray(col:Int) -> [[Element]]{
        var factor = col
        let groupRows = Int(self.count / factor)
        var res : [[Element]] = []
        var count = 0
        while(count < groupRows){
            let start = count * factor
            let end = (count + 1) * factor
            let middle = Array(self[start..<end])
            count += 1
            res.append(middle)
        }
//        print("parseGridItems has been called ! :\(res.count)")
        return res
    }
    
}


struct ExploreTabView: View {
    @EnvironmentObject var mainStates:AppStates
    @State var exploreList : [ExploreData] = []
    @State var onAppear:Bool = false
    @StateObject var IMD = ImageDownloader()
    var dispatchGroup:DispatchGroup = .init()
    func getTrendingItems(){
        print("Get trending Items is being called ! : \(self.exploreList.count)")
        dispatchGroup.enter()
        var res:[TrendingCardData] = []
        for collection in ["posts"]{
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
    
    
    var rowWidth:CGFloat = totalWidth - 20


    var exploreView: some View {
//        var data = self.parseGridItems().enumerated()
        return ScrollView(.vertical, showsIndicators: false) {
            
//            LazyVStack(alignment: .leading, spacing: 0) {
            MainText(content: "Explore", fontSize: 40, color: .black, fontWeight: .semibold, style: .heading)
                .padding(.leading,15)
                .padding(.bottom,30)
                .frame(alignment: .leading)
            ForEach(Array(self.exploreList.TwoDArray(col: 6).enumerated()),id:\.offset){_grid in
                let grid = _grid.element
                let idx = _grid.offset%2
                LazyVStack{
                    FancyGrid(data: Array(grid[0..<3]), direction: idx == 0 ? .left : .right)
                    NormalGrid(data: Array(grid[3...]))
                }
            }
            Spacer().frame(height: 200)
//            }
        }.frame(width: totalWidth, alignment: .center)
    }
    
    var body: some View{
        self.exploreView
            .padding(.top,50)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if !self.onAppear && self.exploreList.isEmpty{
                print("calling on Appear")
                self.onAppear = true
                self.getTrendingItems()
                dispatchGroup.notify(queue: .main) {
                    if self.mainStates.loading{
                        self.mainStates.loading = false
                    }
                }
            }
        }
        
    }
}



struct ExploreTabView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabView()
    }
}
