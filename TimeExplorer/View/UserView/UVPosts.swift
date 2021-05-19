//
//  UVPosts.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/27/20.
//

import SwiftUI

struct UVPosts: View {
    @EnvironmentObject var mainStates:AppStates
    @Binding var selectedPost:PostData
    @Binding var showPost:Bool
    @Binding var selectedImage:UIImage
    @State var leftCol:[PostData] = []
    @State var rightCol:[PostData] = []
    var tabs:[String] = ["posts","tours","blogs"]
    @StateObject var PAPI:PostAPI = .init()
    @State var selectedTab:String = "posts"
    @State var currentCount :Int = 10
    @State var currentPage:Int = 0
    @State var posts:[PostData] = []
    var animation:Namespace.ID
    
    var allPosts:[PostData]{
        get{
            return self.PAPI.posts
        }
    }
    
    func getRightLeft(posts:[PostData]){
        posts.enumerated().forEach { (p) in
            if p.offset%2 == 0{
                self.leftCol.append(p.element)
            }else{
                self.rightCol.append(p.element)
            }
        }
    }
    
    
    var username:String{
        get{
            return self.mainStates.userAcc.user.username ?? ""
        }
    }

    func singleVGrid(_ width:CGFloat,_ side:String) -> some View{
        let _posts:[PostData] = side.lowercased() == "right" ? rightCol : leftCol
        let view = VStack(alignment: .center, spacing: 5) {
            ForEach(_posts,id:\.id){post in
                PostCard(post, $selectedPost, $selectedImage, $showPost, width * 0.9)
                    .matchedGeometryEffect(id: post.id, in: self.animation,properties: .size,isSource: true)
                    .padding()
            }
            Spacer()
        }.frame(width:width).aspectRatio(contentMode: .fit)
        
        return view
    }
    
    
    func onAppear(){
        if self.PAPI.posts.isEmpty{
            self.PAPI.getPosts(user: self.username)
        }
    }
    
    func onRecieve(posts:[PostData]){
        print("Received posts with length : \(posts.count)")
        if posts.count < 0 {
            return
        }
        self.leftCol = []
        self.rightCol = []
        self.getRightLeft(posts: posts.count <= self.currentCount ? posts : Array(posts[0..<self.currentCount]))
    }
    
    var customVGrid:some View{
            HStack(alignment:.top,spacing: 5){
                self.singleVGrid(AppWidth  * 0.5, "left")
                self.singleVGrid(AppWidth  * 0.5, "right")
            }.padding(.horizontal)
    }
    
    var pickerView:some View{
        HStack(alignment:.center){
            ForEach(self.tabs, id:\.self){tab in
                VStack{
                    MainText(content: tab.capitalized, fontSize: 12, color: .black, fontWeight: .bold)
                        .foregroundColor(self.selectedTab == tab ? .black : .gray)
                        .onTapGesture(count: 1, perform: {
                            self.selectedTab = tab
                        })
                        .animation(.easeIn)
                    Circle().frame(width:3,height:3).foregroundColor(self.selectedTab == tab ? .black  : .clear).animation(.easeIn)
                    
                }.frame(height:15).padding()
            }
            Spacer()
        }.frame(width:AppWidth).padding()
    }
    
    var loadMoreButton:some View{
        HStack{
            Spacer()
            Button {
                self.currentCount += 10
                if self.allPosts.count <= self.currentCount{
                    self.PAPI.getPosts(user: self.username)
                }else{
                    let posts = Array(self.allPosts[0..<self.currentCount])
                    self.leftCol = []
                    self.rightCol = []
                    self.getRightLeft(posts: posts)
                }
                
            } label: {
                MainText(content: "Load More", fontSize: 10,color: .black)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.35)))
            }
            Spacer()
        }
    }
    
    var activetabView:some View {
        Group{
            if self.selectedTab == "posts"{
                VStack{
                    self.customVGrid
                    self.loadMoreButton
                }
            }
            if self.selectedTab == "blogs"{
                BlogsCarousel()
            }
        }
    }

    
    var body: some View {
        VStack(alignment:.center){
            self.pickerView
            self.activetabView
        }.padding()

        .onAppear(perform: self.onAppear)
        .onReceive(self.PAPI.$posts, perform: self.onRecieve(posts:))
    }
}

struct PostCard:View{
    var post:PostData
    var width:CGFloat = totalWidth * 0.40
    @Binding var selectedPost: PostData
    @Binding var image:UIImage
    @Binding var showPost:Bool
    @StateObject var VidD:VideoDownloader = .init()
    init(_ post:PostData, _ selectedPost:Binding<PostData>, _ image:Binding<UIImage>, _ showPost:Binding<Bool>,_ width:CGFloat? = nil){
        self.post = post
        if let w = width{
            self.width = w
        }
        self._selectedPost = selectedPost
        self._image = image
        self._showPost = showPost
    }
    var mainPostCard:some View{
        ImageView(url: self.post.image?.first, width: self.width, height: 175, contentMode: .fill,autoHeight: true)
            .clipped()
            .cornerRadius(25.0)
            .overlay(
                ZStack(alignment: .bottom){
                    Image("bottomBackground")
                        .resizable()
                        .frame(width:self.width)
                        .aspectRatio(UIImage.aspectRatio(name: "bottomBackground"),contentMode: .fit)
                        .clipShape(Corners(rect: [.bottomRight,.bottomLeft],size: .init(width: 25.0, height: 25.0)))
                    VStack(alignment: .leading){
                        Spacer()
                        HStack{
                            MainText(content: self.post.caption, fontSize: 10, color: .white, fontWeight: .regular)
                            Spacer()
                        }.padding(.horizontal)
                        
                    }.padding(.bottom)
                }
                
                
            )
            .animation(.default)
    }
    
    var body: some View{
        Button {
            self.selectedPost = self.post
//            self.image = self.IMD.image
            self.showPost = true
        } label: {
            self.mainPostCard
        }.buttonStyle(PlainButtonStyle())
    }
}

