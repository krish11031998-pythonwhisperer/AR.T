//
//  PVMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/19/20.
//

import SwiftUI

struct PostID:Identifiable{
    var id:Int
    var post:InstaPostData
    var date:Date?
}

struct PVMain: View {
    @StateObject var PAPI:PostAPI = .init()
    @Environment (\.modalTransitionPercent) var pct:CGFloat
    @StateObject var ImgD:ImageDownloader = .init()
    @State var show:Bool = false
    @State var s_posts:[PostData] = []
    @Binding var showPost:Bool
    @State var loadMore:Bool = false
    @State var count:Int = 10
    @Binding var showPosts:Bool
    @EnvironmentObject var mainStates:AppStates
    init(cityName:String,showPost:Binding<Bool>,tabstate:Binding<Bool> = .constant(false),show:Binding<Bool> = .constant(false)){
        self._showPost = showPost
        self._showPosts = show
    }
    
    
    var data:[PostData]{
        get{
            return self.PAPI.posts
        }
    }
    
    
    func loadMorePosts(){
        self.loadMore.toggle()
        self.count += 10
        if self.PAPI.posts.count < self.count{
            self.PAPI.getPosts(user: self.mainStates.userAcc.username)
        }
        
        print("Loading more posts!")
    }
    
    
    func onReceive(){
        if(!self.data.isEmpty){
            if(self.loadMore){
                self.loadMore = false
            }
        }else{
            print("recieving self.mainStates.PAPI.posts")
            if self.loadMore{
                self.loadMore = false
            }
        }

    }
    
    var storyPosts:[String:[PostData]]{
        get{
            var result:[String:[PostData]] = [:]
            var keys:Set<String> = Set(self.data.compactMap({$0.user}))
            keys.forEach { (key) in
                result[key] = self.data.filter({$0.user != nil ? $0.user! == key : false})
            }
            return result
        }
    }

    var _posts:some View{
            LazyVStack{
                ForEach(Array(self.data.enumerated()), id: \.offset){ _post in
                    let post = _post.element
                    let idx = _post.offset
                    VStack(alignment:.center){
                        SinglePostView(post: post) {
                            if idx == self.data.count - 1{
                                self.loadMore = true
                            }
                        }
                        Divider().frame(width: AppWidth * 0.75, height: 1, alignment: .center).padding(.vertical,10)
                    }
                    
                }
            }
        .animation(.spring())
    }
    
    
    var loadMoreView: some View{
        GeometryReader{g -> AnyView in
            var maxY = g.frame(in: .global).maxY
            if maxY < totalHeight{
//                print("Load more is called upon")
                DispatchQueue.main.async {
                    if !self.loadMore{
                        self.loadMorePosts()
                    }
                }
                
            }
            
            return AnyView(
                Color.white.frame(height:200)
            )
            
        }
    }
    
    var addPostButton:some View{
        Button(action: {
            self.mainStates.tab = "post"
        }, label: {
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20, alignment: .center)
        })
    }
    
    var mainPostView: some View{
        var size = self.modalParams()
        return ScrollView(.vertical, showsIndicators: false){
            HStack{
                TabBarButtons(bindingState: $showPosts)
                MainText(content: "Posts", fontSize: 40, color: .black, fontWeight: .medium,style:.heading)
                Spacer()
                self.addPostButton
            }.padding(.horizontal,15)
            .padding(.top,50)
            if !self.data.isEmpty{
                VStack{
                    SVRows(stories: self.storyPosts, show: self.$show, s_posts: self.$s_posts)
                        .zIndex(3)
                    self._posts.padding(.vertical).clipped()
                    self.loadMoreView.frame(height: 200, alignment: .center)
                }
            }
        }
        .background(Color.white)
        .frame(width:size.width,height: size.height) 
    }
    
    func modalParams() -> CGSize{
        let width = totalWidth * 0.75
        let height = totalHeight * 0.5
        let diff:CGSize = .init(width: 0.25 * totalWidth, height: 0.5 * totalHeight)
        
        let final_w = width + diff.width * pct
        let final_h = height + diff.height * pct
        
        print("PVMain pct :",pct)
        return .init(width: final_w, height: final_h)
    }
    
    
    
    
    var allPostsView: some View{
        self.mainPostView
            .onChange(of: self.loadMore, perform: { (loadMore) in
                if loadMore{
                    self.loadMorePosts()
                }
            })
            
            .onAppear {
                if self.PAPI.posts.isEmpty{
                    self.PAPI.getTopPosts(limit: 10)
                }
            }
            .onReceive(self.PAPI.$posts) { _ in
                self.onReceive()
            }
        .navigationTitle("")
        .navigationBarHidden(true)
        
        
    }
    
    var body: some View {
        
        return ZStack{
//            Color.black
            self.allPostsView
                .zIndex(1)
            if self.show{
                StoryView(show: self.$show, images:Array(self.s_posts[0...9]))
                    .animation(.easeInOut)
                    .zIndex(2)
            }
        }
        
        .edgesIgnoringSafeArea(.all)
    }
}

struct Post_Previews:PreviewProvider{
    static var previews: some View{
        PVMain(cityName: "", showPost: .constant(false))
    }
}
