//
//  SVRows.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/10/20.
//

import SwiftUI

struct SVRows: View {
    var stories:[String:[PostData]]
    @EnvironmentObject var mainStates:AppStates
    @Binding var show:Bool
    
    @Binding var s_posts:[PostData]
    func _posts(key:String) -> [PostData]{
        return self.stories[key] ?? []
    }
    
    var _keys:[String]{
        get{
            return Array(self.stories.keys).sorted { (a, b) -> Bool in
                return a.compare(b) == .orderedAscending
            }
        }
    }
    

  
    var body: some View {
        ScrollView(.horizontal,showsIndicators:false){
            HStack{
                ForEach(_keys, id :\.self){ key in
                    Button {
                        self.show.toggle()
                        self.s_posts = self._posts(key: key)
                        self.mainStates.showTab = false
                        print("Clicked on the StoryCircle")
                    } label: {
                        StoryCircle(storyPosts: self._posts(key: key),key:key).padding(.leading, self._keys.index(of: key) ?? 0 == 0 ? 20 : 0)
                    }
                    
                }
            }
        }.frame(height:totalHeight/6).padding(.top)
    }
}

struct StoryCircle: View{
    @StateObject var IMD:ImageDownloader = .init()
//    var storyPosts:[IPDNode]
    var storyPosts:[PostData]
    let width:CGFloat = totalWidth/6
    let key:String
    var imgURL:String{
        get{
//            return self.storyPosts.first?.node?.display_url ?? ""
            return self.storyPosts.first?.image?.first ?? ""
        }
    }
    var body: some View{
        VStack(alignment:.center,spacing: 0){
            Image(uiImage:self.IMD.image ?? .stockImage)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(UIImage.aspectRatio(img: self.IMD.image),contentMode: .fill)
                    .frame(width: 75,height:75)
                    .clipShape(Circle())
            MainText(content: self.key, fontSize: 12.5, color: .black, fontWeight: .regular)
//                .padding(.vertical)
                .padding()
        }.aspectRatio(contentMode: .fit).padding(.vertical,10).padding(.top,10)
        .onAppear(perform: {
            self.IMD.getImage(url: self.imgURL)
        })
                
    }
}
