//
//  UVDetail.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/28/20.
//

import SwiftUI


struct ProfileImage:View{
    var url:String? = nil
    var image:UIImage? = nil
    var width:CGFloat
    init(_ url:String? = nil, _ image:UIImage? = nil, _ a:CGFloat){
        if let url = url{
            self.url = url
        }
        if let image = image{
            self.image = image
        }
        self.width = a
    }
    
    var mainImage:UIImage{
        get{
            if self.image == nil{
                return .loadImageFromCache(self.url)
            }else if let image = self.image{
                return image
            }
            
            return UIImage.stockImage
        }
    }
    
    var body: some View{
        Image(uiImage: self.mainImage)
            .resizable()
            .aspectRatio(UIImage.aspectRatio(img:self.mainImage),contentMode:.fill)
            .frame(width:self.width,height:self.width)
            .clipShape(Circle())
    }
    
    
}

struct PostButtonView:View{
    
    var name:String = ""
    var value:String = ""
    var color:Color = .white
    var blurStyle:UIBlurEffect.Style = .regular
    var body: some View{
        HStack(alignment:.center){
            Image(systemName: name)
                .resizable()
                .frame(width: 15, height: 15, alignment: .center)
                .foregroundColor(color)
                .padding(5)
            MainText(content: value, fontSize: 10, color: .white, fontWeight: .regular)
        }.padding().background(BlurView(style: blurStyle).clipShape(RoundedRectangle(cornerRadius: 25.0)))
    }
}


struct PostTopHeader:View{
    @Binding var showPost:Bool
    var profilePic:UIImage = .init()
    
    func profileImage(a:CGFloat = 50) -> some View{
        return ImageView(img: self.profilePic, width: a, height: a, contentMode: .fill)
            .clipShape(Circle())
    }
    
    
    var body:some View{
        VStack{
            HStack(alignment:.center){
                TabBarButtons(bindingState: self.$showPost).padding().background(Circle().fill(Color.gray.opacity(0.35)))
                Spacer()
                self.profileImage()
                Spacer()
                Button(action: {
                    print("Options Pressed!")
                }, label: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .frame(width: 15, height: 15, alignment: .center)
                        .padding()
                        .background(BlurView(style: .regular).clipShape(Circle()))
                })
            }.padding(.horizontal).padding(.vertical).frame(height:100)
        }
    }
}

struct UVDetail:View{
    var profilePic:UIImage
    var userName:String
    @State var post:PostData
    @State var AnyChange:Bool = false
    @Binding var showPost:Bool
    @EnvironmentObject var mainStates:AppStates
    var postImg:UIImage? = nil
    var topHeader:PostTopHeader?
    var profileImageView:ProfileImage?
    
    init(profilePic:UIImage, userName:String,post:PostData,showPost:Binding<Bool>,postImg:UIImage? = nil){
        self.profilePic = profilePic
        self.userName = userName
        self._post = State(initialValue: post)
        self.postImg = postImg
        self._showPost = showPost
        self.topHeader = .init(showPost: self.$showPost, profilePic: self.profilePic)
        self.profileImageView = .init(nil, profilePic, 50)
    }
    
    
    var isVideoPost:Bool{
        get{
            return self.post.isVideo ?? false
        }
    }
    
    var v5:some View{
            ZStack{
                if self.isVideoPost{
                    VideoPostView(self.$post, self.profileImageView!, self.userName, self.topHeader!, self.postImg ?? .stockImage, $AnyChange)
                }else{
                    ImagePostView(self.$post, self.$showPost, self.topHeader!, self.profileImageView!, self.userName, self.postImg, $AnyChange)
                }
            }

    
        }
    
    var body: some View{
        self.v5
            .edgesIgnoringSafeArea(.all)
            .onAppear(perform: {
                self.mainStates.showTab = false
                
            })
            .onDisappear(perform: {
                if !self.mainStates.showTab && self.mainStates.tab != "feed"{
                    self.mainStates.showTab.toggle()
                }
                DispatchQueue.global(qos: .background).async {
                    if AnyChange{
                        self.mainStates.PAPI.updatePost(self.post)
                    }
                }
            })
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.vertical)
    }
    
}

struct ImagePostView: View{
    @Binding var post:PostData
    @StateObject var IMD:ImageDownloader = .init()
    @StateObject var SP:swipeParams = .init()
    @Binding var showPost:Bool
    @State var showLike:Bool = false
    @State var showCommentSection:Bool = false
    @Binding var AnyChange:Bool
    @State var commentString:String = ""
    @State var alreadyLiked:Bool = false
    @State var showOriginalPhoto:Bool = false
    var postImg:UIImage? = nil
    var postTopHeader:PostTopHeader
    var profileImageView:ProfileImage
    var username:String
    
    init(_ post:Binding<PostData>,_ showPost:Binding<Bool>,_ topHeader:PostTopHeader, _ profileImageView:ProfileImage, _ username:String, _ postImg:UIImage?, _ anyChange:Binding<Bool>){
        self._post = post
        self._showPost = showPost
        self.postTopHeader = topHeader
        self.profileImageView = profileImageView
        self.profileImageView.width = 40
        self.username = username
        if let postImg = postImg{
            self.postImg = postImg
        }
        self._AnyChange = anyChange
    }
    
    
    var postImage:UIImage{
        get{
            return self.postImg ?? self.IMD.image ?? .stockImage
        }
    }
    
    var imageHeight:CGFloat{
        return totalHeight * 0.45
    }
    
    var backgroundHeight:CGFloat{
        return totalHeight * CGFloat(!self.showCommentSection ? 1 : 0.5)
    }
    
    func button(w width:CGFloat, h height:CGFloat) -> some View{
        return HStack(alignment: .center, spacing: 10){
            PostButtonView(name:"heart.fill", value:"\(self.post.likes ?? 0)", color: .red)
            PostButtonView(name: "message.fill", value: "\(self.post.comments?.count ?? 0)", color:.purple)
            Spacer()
        }.frame(width: width,height: height)
    }
    
    func likeFunction(){
        print("You pressed like !")
        self.showLike.toggle()
        self.post.likes = self.post.likes ?? 0 + 1
        if !self.AnyChange{
            self.AnyChange.toggle()
        }
    }
    
    
    func expandImg(){
        self.showOriginalPhoto.toggle()
    }
    
    func postView(w width:CGFloat, h height:CGFloat) -> some View{
        return
            ImageView(url: self.post.image?.first, width: width, height: height, contentMode: .fill)
            .fixedSize()
            .clipped()
            .clipShape(Corners(rect: [.topLeft,.bottomRight], size: .init(width: 15, height: 15)))
            .clipShape(Corners(rect: [.topRight,.bottomLeft], size: .init(width: 30, height: 30)))
            .animation(.easeInOut)
            .onTapGesture(count: 2, perform: self.likeFunction)
            .onTapGesture(perform: self.expandImg)
            .overlay(
                ZStack{
                    if self.showLike{
                        LikeView(self.$showLike)
                    }
                }
            ).padding(.top,10)
            
    }

    func blurredBackGround(w width:CGFloat,h height:CGFloat) -> some View{
        return ImageView(url: self.post.image?.first, width: width,height: height, contentMode: .fill)
            .blur(radius: 50)
            .cornerRadius(25.0)
            .shadow(radius: 10)
            .edgesIgnoringSafeArea(.top)
    }
    
    func blurMainImage(w width:CGFloat,h height:CGFloat) -> some View{
        let view = GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            VStack(alignment: .leading, spacing: 10){
                self.postTopHeader
                    .zIndex(2)
                Group{
                    self.postView(w: w, h: h * (showOriginalPhoto && !showCommentSection ? 0.75 : 0.45))
                    if !self.showOriginalPhoto{
                        self.button(w: width, h: 50).padding()
                    }
                    if !self.showOriginalPhoto && !self.showCommentSection{
                        ScrollView{
                            MainText(content: self.post.caption, fontSize: 20, color: .white, fontWeight: .bold)
                                .frame(width:w,alignment: .leading)
                        }.animation(.easeInOut)
                        .aspectRatio(contentMode: .fit)
                        .frame(width:w)
                    }
                }.zIndex(1)
            }
        }.padding(25).frame(width: width, height: height, alignment: .top)
        .background(blurredBackGround(w: width, h: height))
        .animation(.easeInOut)
        return view
    }
    
    func addComment(){
        if self.post.comments == nil{
            self.post.comments = [commentString]
        }else{
            self.post.comments?.append(commentString)
        }
        print(self.post.comments)
        if !self.AnyChange{
            self.AnyChange = true
        }
    }
    
    func commentSection(w width:CGFloat,h height:CGFloat) ->some View{
        VStack {
            self.allCommentsView.padding(.top,25)
            HStack(alignment:.center){
                self.profileImageView.padding()
                TextField("Add Comment", text: self.$commentString)
                Button(action: self.addComment, label: {
                    MainText(content: "Send", fontSize: 10)
                        .padding(10)
                }).padding(5)

            }.frame(width:AppWidth)
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.white).shadow(radius: 10))
            Spacer().frame(height:25)
        }.padding(.top,25).frame(width: width, height: height, alignment: .center).animation(.easeInOut)
    }
    
    var allCommentsView:some View{
        GeometryReader{g in
            var width = g.frame(in: .local).width
            var height = g.frame(in: .local).height
            ScrollView(.vertical, showsIndicators: false){
                if let comments = self.post.comments{
                    ForEach(comments,id: \.self){comment in
                        VStack{
                            HStack(alignment: .center, spacing: 10){
                                self.profileImageView
                                VStack(alignment: .leading){
                                    MainText(content: "\(self.username)", fontSize: 10, color: .black, fontWeight: .regular)
                                        .fixedSize(horizontal: false, vertical: true)
                                    MainText(content: comment, fontSize: 15, color: .black, fontWeight: .regular)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }.padding(.vertical,5).padding(.horizontal).frame(width:width)
                            Divider().padding().frame(width:width)
                        }
                    }
                }else{
                    MainText(content: "No Comments", fontSize: 20, color: .black, fontWeight: .medium)
                }
                    
            }
        }.frame(width: AppWidth, alignment: .center)
    }
    
    
    func onEnded(value:CGFloat){
        if (value < 0 && !self.showCommentSection && -value > 50) || (value > 0 && self.showCommentSection &&  value > 50){
            self.showCommentSection.toggle()
            self.SP.extraOffset = 0
        }
    }
    
    var body: some View{
        
        GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            VStack{
                self.blurMainImage(w: w, h: totalHeight * (self.showCommentSection ? 0.5 : 1))
                
                if self.showCommentSection{
                    self.commentSection(w: w, h: totalHeight * (self.showCommentSection ? 0.5 : 0))
                }
            }.frame(width: w, height: h, alignment: .center)
            .gesture(DragGesture()
                        .onEnded({ (value) in
                            self.onEnded(value: value.translation.width)
                        }))
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
        
            
    }
    
}

struct VideoPostView: View{
    @Binding var post:PostData
    @StateObject var IMD:ImageDownloader = .init()
    @StateObject var VID:VideoDownloader = .init()
    @Binding var AnyChange:Bool
    var profileImageView:ProfileImage
    var topHeader:PostTopHeader
    var thumbnailImg:UIImage
    var userName:String = ""
    @State var playVid:Bool = true
    @State var videoPlayer:PlayerView = PlayerView(videoURL: nil,.init(x: 0, y: 0, width: totalWidth, height: totalHeight))
    @State var showLike:Bool = false
    @State var alreadyLiked:Bool = false
    
    
    init(_ post:Binding<PostData>,_ profileImageView:ProfileImage,_ username:String, _ topHeader:PostTopHeader, _ thumbnail:UIImage, _ anyChange:Binding<Bool>){
        self._post = post
        self.profileImageView = profileImageView
        self.profileImageView.width = 60
        self.userName = username
        self.topHeader = topHeader
        self.thumbnailImg = thumbnail
        self._AnyChange = anyChange
    }
    
    
    var userPostInfo:some View{
        GeometryReader{g in
            var width = g.frame(in:.local).width
            var height = g.frame(in: .local).height
            ZStack(alignment: .bottom){
//                Image.bottomShadow.resizable().aspectRatio(contentMode: .fill)
                VStack(alignment:.leading,spacing: 10){
                    Spacer()
                    HStack(alignment: .center, spacing: 10) {
//                        self.profileImageView
//                        MainText(content: self.userName, fontSize: 15, color: .white, fontWeight: .regular)
//                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }.padding(.horizontal)
                    MainText(content: "@\(self.userName)", fontSize: 12.5, color: .white, fontWeight: .medium)
                        .fixedSize(horizontal: false, vertical: true)
                    MainText(content: self.post.caption, fontSize: 17.5, color: .white, fontWeight: .regular)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom,10)
                    Spacer().frame(height: 50)
                }.padding().frame(width:width,height:height)
            }.edgesIgnoringSafeArea(.bottom).frame(width:width,height:height).padding(.bottom)
        }
    }
    
    var postOptions:some View{
        VStack{
            self.profileImageView.padding()
            PostButtonView(name:"heart.fill", value:"\(self.post.likes ?? 0)", color:.red)
                .onTapGesture(count: 1) {
                    if !self.alreadyLiked{
                        self.post.likes = self.post.likes != nil ? self.post.likes! + 1 : 1
                        if !self.AnyChange{
                            self.AnyChange.toggle()
                        }
                        self.alreadyLiked.toggle()
                    }
                    self.showLike.toggle()
                    
                }
            PostButtonView(name:"message.fill", value:"\(self.post.comments?.count ?? 0)", color: .purple)
        }.padding()
    }
    
    
    
    var videoView:some View{
        return GeometryReader{g in
            var width = g.frame(in:.local).width
            var height = g.frame(in: .local).height
//            self.videoPlayer.player_frame = CGRect(x: 0, y: 0, width: width, height: height)
            ZStack(alignment: .bottom){
                if self.VID.videoURL == nil{
                    Image(uiImage: self.thumbnailImg)
                        .resizable()
                        .frame(width: width, height: height)
                        .aspectRatio(UIImage.aspectRatio(img: self.IMD.image),contentMode:.fill)
                }else if self.VID.videoURL != nil{
//                    PlayerView(videoURL: self.VID.videoURL, readyToPlay: self.$playVid,.init(x: 0, y: 0, width: width, height: height))
                    self.videoPlayer
                }
                VStack{
                    Image.topShadow.resizable().frame(width: width,height:height * 0.25).aspectRatio(contentMode: .fill)
                    Spacer()
                    if self.showLike{
                        LikeView(self.$showLike)
                    }
                    Image.bottomShadow.resizable().frame(width: width,height: height * 0.25).aspectRatio(contentMode: .fill)
                }.frame(width:width,height:height).edgesIgnoringSafeArea(.bottom)
                VStack{
                    self.topHeader.padding(.top,20)
                    Spacer()
                    HStack{
                        self.userPostInfo.frame(width: width*0.7)
                        self.postOptions.frame(width: width*0.3)
                    }.frame(height: height*0.5)
                }.frame(width:width,height:height)
                
            }.frame(width: width, height: height)
        }.frame(width:totalWidth,height:totalHeight)
    }
    
    
    var body:some View{
        self.videoView
            .onAppear {
                
                if let img = self.post.image?.first, img != self.IMD.url{
                    self.IMD.getImage(url: img)
                }
                if let video = self.post.video?.first{
                    self.VID.downloadVideo(video_id: self.post.id ?? UUID().uuidString, urlString: video)
                }
            }
            .onReceive(self.VID.$videoURL, perform: { (url) in
                if let url = url{
                    self.videoPlayer.vid_url = url
//                    self.videoPlayer.player?.play()
                }
            })
            .onDisappear {
                if let status = self.videoPlayer.player?.timeControlStatus, status == .playing{
//                    self.playVid = false
                    self.videoPlayer.stopVideo()
                    self.videoPlayer.player = nil
                }
            }
            .onTapGesture {
                self.videoPlayer.changeStatus.toggle()
            }
            
    }

    
}


//struct UVDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        UVDetail()
//    }
//}
