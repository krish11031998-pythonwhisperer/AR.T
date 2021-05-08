//
//  TopPostCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 07/12/2020.
//

import SwiftUI

struct TopPostCarousel: View {
    @StateObject var PostManager:PostAPI = .init()
    @StateObject var imageManager: ImageDownloader = .init()
    @EnvironmentObject var mainStates:AppStates
    @State var topfourImages:[PostData] = []
    @State var selectedPost:PostData? = nil
    @State var showPost:Bool = false
//    @State var tabNum:Int = 0
//    private var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var topImage:some View{
        
        var view = VStack(alignment:.center,spacing:0){
            if !self.topfourImages.isEmpty{
                VStack(alignment:.center){
                    HStack{
                        MainText(content: "Top Posts", fontSize: 25, color: .black, fontWeight: .bold,style: .heading)
                            .padding(.leading,25)
                        Spacer()
                    }
                    self.topFourTabView.padding(.vertical)
                }.padding().padding(.vertical,50).frame(width:AppWidth,height: 500)
            }
            NavigationLink(destination: UVDetail(profilePic: .stockImage, userName: "name", post: self.selectedPost ?? .init(caption: ""), showPost: self.$showPost, postImg: self.imageManager.images[self.selectedPost?.image?.first ?? ""]), isActive: self.$showPost) {
                MainText(content: "Test", fontSize: 1)
            }.hidden()
        }.padding(50)
        .frame(width: AppWidth)
//        .background(BlurView(style: .systemMaterialDark).clipShape(ArcCorners(curveFactor: 0.1)))
        return view
    }
    

    var topFourTabView: some View{
        GeometryReader{g in
            var posts = Array(self.topfourImages.enumerated())
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            TabView{
                ForEach(posts,id: \.offset){ postObj  in
                    var post = postObj.element
                    var num = postObj.offset
                    var img = self.imageManager.images[post.image?.first ?? ""] ?? .stockImage
                    TopPostCard(post: post,postImage: img, showPost: self.$showPost, selectedPost : self.$selectedPost, width: w, height: h)
                        .padding().frame(width:w,height:h)
                        .tag(num)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .padding(.horizontal).frame(width: AppWidth, height: 500, alignment: .center)
    }
    

    
    
    var body: some View {
        self.topImage
            .onAppear(perform: {
                if self.PostManager.posts.isEmpty{
                    print("Top post is going to be fetched !")
                    self.PostManager.getTopPosts(limit: 5)
                }
            })
            .onReceive(PostManager.$posts, perform: { posts in
                if !posts.isEmpty{
                    self.topfourImages = posts
                    if self.imageManager.images.isEmpty{
                        self.imageManager.getImages(urls: self.topfourImages.compactMap({$0.image?.first}))
                    }
                }
            })
    }
}


struct TopPostCard:View{
    var post:PostData
    var w:CGFloat = 0
    var h:CGFloat = 0
    var img:UIImage
    @Binding var showPost:Bool
    @Binding var selectedPost:PostData?
    
    init(post:PostData,postImage image:UIImage,showPost:Binding<Bool>, selectedPost:Binding<PostData?>,width w:CGFloat, height h:CGFloat){
        self.post = post
        self.img = image
        self.w = w
        self.h = h
        self._showPost = showPost
        self._selectedPost = selectedPost
    }
    
    
//    func PostTab(_ post:PostData,width w:CGFloat, height h:CGFloat) -> some View{
    var body: some View{
        var img = post.image?.first ?? ""
        var view_w = w * 0.9
        return VStack(alignment: .leading, spacing: 5) {
                ZStack(alignment:.top){
                    Color.clear
                    Image(uiImage:self.img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: view_w,height: h)
                        .clipShape(ArcCorners(corner: .bottomRight, curveFactor: 0.1))
                        .overlay(
                            ZStack(alignment: .top){
                                overlayShadows(width: view_w,height: h)
                                    .clipShape(ArcCorners(corner: .bottomRight, curveFactor: 0.1))
                                VStack(alignment: .leading){
                                    HStack{
                                        Spacer()
                                    }.padding(.horizontal)
                                    MainText(content: post.user ?? "", fontSize: 12, color: .white, fontWeight: .medium)
                                        .padding()
                                    Spacer()
                                    MainText(content: post.caption, fontSize: 12, color: .white, fontWeight: .medium)
                                        .padding()
                                        .background(BlurView(style: .dark).clipShape(Capsule()))
                                        .padding()
                                    HStack{
                                        
                                        PostButtonView(name: "heart.fill", value: "\(post.likes ?? 0)", color: .white, blurStyle: .regular).padding(.leading,5)
                                        PostButtonView(name: "message.fill", value: "\(post.comments?.count ?? 0)", color: .white, blurStyle: .regular)
                                        Spacer()
                                    }.padding().frame(width: view_w, height: h * 0.125)
                                    Spacer().frame(height: 35)
                                }.padding()
                            }.padding().clipShape(ArcCorners(corner: .bottomRight, curveFactor: 0.1))
                        )
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Button {
                                self.showPost.toggle()
                                self.selectedPost = post
                            } label: {
                                MainText(content: "View Post", fontSize: 12, color: .white, fontWeight: .medium, style: .normal)
                                    .padding()
                                    .background(BlurView(style: .dark).cornerRadius(30))
                            }
                        }.padding()
                    }
                }.padding().frame(width:w,height:h).cornerRadius(45)
            
            
        }
    }
}

struct TopPostCarousel_Previews: PreviewProvider {
    static var previews: some View {
        TopPostCarousel()
    }
}
