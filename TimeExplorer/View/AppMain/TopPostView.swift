//
//  PostView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 17/03/2021.
//

import SwiftUI

struct TopPostView: View {
    @StateObject var PAPI:PostAPI = .init()
    @State var currentIdx : Int = 0
    @State var selectedPost:PostData? = nil
    var viewMore:() -> Void
    @State var resetStack:Bool = false
    @State var rotationAngles:[Double] = []
    var animation:Namespace.ID
    
    init(animation:Namespace.ID,_ viewMore:@escaping (() -> Void)){
        self.animation = animation
        self.viewMore = viewMore
    }
    
    var posts:[PostData]{
        get{
            return self.PAPI.posts.filter({!($0.isVideo ?? false)})
        }
    }
    
    var PolaroidStack:some View{
        ZStack(alignment:.center){
            FinalCard(currentIdx: $currentIdx, resetStack: $resetStack, viewMore: {
                self.viewMore()
            })
            .scaleEffect(self.currentIdx == self.posts.count ? 1 : 0.7)
            .matchedGeometryEffect(id: "postsViewMain", in: self.animation,properties: .frame,anchor: .top)
            .transition(.invisible)
            ForEach(Array(self.posts.enumerated()).reversed(),id:\.offset){ _post in
                let post = _post.element
                let idx = _post.offset
                let current = idx == self.currentIdx
                let diff = abs(idx - self.currentIdx)
                let scale = 1 - CGFloat(diff <= 2 ? diff : 2) * 0.01
                let isVideo = !(post.isVideo ?? false)
//                if isVideo{
                    PostCardView(post: post, selectedPost: self.$selectedPost, current: self.$currentIdx, reset:self.$resetStack,isTop:current)
                            .scaleEffect(scale)
                            .rotationEffect(.init(degrees: self.rotationAngles[idx]))
//                }
                
            }
        }.animation(.interactiveSpring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5))
    }
    
    var body: some View {
        self.PolaroidStack
            .onAppear(perform: {
                if self.PAPI.posts.isEmpty{
                    self.PAPI.getTopPosts(limit: 10)
                }
            })
            .onReceive(self.PAPI.$posts) { (posts) in
                self.rotationAngles = Array(repeating: 1, count: posts.count).map({$0 * Double.random(in: -10.0...10.0)})
            }
    }
}

struct FinalCard:View{
    
    @Binding var currentIdx:Int
    @Binding var resetStack:Bool
    var viewMore: (() -> Void)
    
    var body: some View{
        VStack(alignment: .center, spacing: 10){
            
            SystemButton(b_name: "arrow.forward.circle", b_content: "View More") {
                self.viewMore()
            }
            
            SystemButton(b_name: "arrow.clockwise", b_content: "Reset") {
                self.currentIdx = 0
                self.resetStack.toggle()
            }
        }.padding()
        .frame(width: totalWidth * 0.75, height: totalHeight * 0.5, alignment: .center)
        .background(
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(radius: 10)
        )
    }
}



struct PostCardView:View{
    var post:PostData
    @Binding var selectedPost:PostData?
    @Binding var current:Int
    @Binding var reset:Bool
    @State var offset:CGFloat = 0
    var isTop:Bool
    init(post:PostData,selectedPost:Binding<PostData?>,current:Binding<Int>,reset:Binding<Bool>,isTop:Bool){
        self.post = post
        self._selectedPost = selectedPost
        self._current = current
        self._reset = reset
        self.isTop = isTop
    }
    
    
    var postImage:String{
        get{
            var res:String = ""
            if let url = self.post.image?.first{
                res = url
            }
            return res
        }
    }
    
    
    func ImageCaptionView(width:CGFloat,height:CGFloat) -> some View{
        return GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            VStack(alignment: .leading, spacing: 5){
//                ImageView(self.postImage, w, h * 0.7, .fill,true)
                ImageView(url:self.postImage,width: w,height: h * 0.9,contentMode:.fill)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                MainText(content: self.post.caption, fontSize: 14, color: .black, fontWeight: .regular)
                    .padding()
                    .frame(width: w , height: h * 0.1, alignment: .leading)
            }
        }.frame(width: width, height: height, alignment: .center)
    }
    
    func onChanged(value:DragGesture.Value){
        if self.isTop{
            var width = value.translation.width
            self.offset = width
        }
        
    }
    
    func onEnded(value:DragGesture.Value){
        if self.isTop{
            var width = value.translation.width
            var dir = CGFloat(width > 0 ? 1 : -1)
            if abs(width) > 75{
                self.offset = totalWidth * 1.5 * dir
                self.current += 1
                print("current : ",current)
            }else{
                self.offset = 0
            }
        }
        

    }
    
    var body: some View{
        GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            
            self.ImageCaptionView(width: w, height: h)
                
            
        }.padding(.horizontal,10)
        .padding(.top,10)
        .padding(.bottom,20)
        .frame(width: totalWidth * 0.75, height: totalHeight * 0.5, alignment: .center)
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 30)).shadow(radius: 1.5))
        .offset(x: self.offset)
        .gesture(DragGesture()
                    .onChanged(self.onChanged)
                    .onEnded(self.onEnded)
        )
        .onChange(of: self.reset, perform: { value in
            if value && self.offset != 0{
                self.offset = 0
                self.reset = false
            }
        })
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5))

    }
}

