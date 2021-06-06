//
//  PostView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 17/03/2021.
//

import SwiftUI

struct TopPostView: View {
    @EnvironmentObject var mainStates:AppStates
    @StateObject var PAPI:PostAPI = .init()
    @State var currentIdx : Int = 0
    @State var selectedPost:PostData? = nil
    var _posts:[PostData]
    var viewMore:() -> Void
    var cardView: ((AVSData,Binding<Int>,Binding<Bool>,Bool) -> AnyView)?
    @State var resetStack:Bool = false
    @State var rotationAngles:[Double] = []
    var animation:Namespace.ID
    
    init(posts:[PostData] = [],animation:Namespace.ID,cardView:((AVSData,Binding<Int>,Binding<Bool>,Bool) -> AnyView)? = nil,_ viewMore: @escaping (() -> Void)){
        self.animation = animation
        self.viewMore = viewMore
        self._posts = posts
        self.cardView = cardView
//        self._rotationAngles = .init(wrappedValue: !posts.isEmpty ? Array(repeating: 1, count: posts.count).map({$0 * Double.random(in: -3.0...3.0)}) : [])
    }
    
    var posts:[PostData]{
        get{
            return self._posts.isEmpty ? self.PAPI.posts.filter({!($0.isVideo ?? false)}) : self._posts
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
                let post = _post.element as PostData
                let idx = _post.offset
                let current = idx == self.currentIdx
                let diff = abs(idx - self.currentIdx)
                let scale = 1 - CGFloat(diff <= 2 ? diff : 2) * 0.01
                if idx <= self.currentIdx + 2{
                    PostCardView(post: post, selectedPost: self.$selectedPost, current: self.$currentIdx, reset:self.$resetStack,isTop:current)
                        .scaleEffect(scale)
                        .rotationEffect(.init(degrees: idx < self.rotationAngles.count ? self.rotationAngles[idx] : 0))
                }
                    
            }
        }.animation(.interactiveSpring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5))
    }
    
    var body: some View {
        self.PolaroidStack
            .onAppear(perform: {
                if self.posts.isEmpty{
                    self.PAPI.getTopPosts(limit: 10)
                }else{
                    self.rotationAngles = Array(repeating: 1, count: posts.count).map({$0 * Double.random(in: -3.0...3.0)})
                }
            })
            .onReceive(self.PAPI.$posts) { (posts) in
                self.rotationAngles = Array(repeating: 1, count: posts.count).map({$0 * Double.random(in: -3.0...3.0)})
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
    
    
    func ImageCaptionView(width w:CGFloat,height h:CGFloat) -> some View{
            return ZStack(alignment: .bottom){
                ImageView(url:self.postImage,width: w,height: h,contentMode:.fill,alignment: .center)
                lightbottomShadow.aspectRatio(contentMode: .fill)
                BasicText(content: self.post.caption, fontDesign: .serif, size: 15, weight: .semibold)
                    .foregroundColor(.white)
                    .padding(20)
                    .frame(width: w, alignment: .leading)
            }
            .frame(width: w, height: h, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    func onChanged(value:DragGesture.Value){
        if self.isTop{
            let width = value.translation.width
            self.offset = width
        }
        
    }
    
    func onEnded(value:DragGesture.Value){
        if self.isTop{
            let width = value.translation.width
            let dir = CGFloat(width > 0 ? 1 : -1)
            if abs(width) > 75{
                self.offset = totalWidth * 1.5 * dir
                self.current += 1
            }else{
                self.offset = 0
            }
        }
        

    }
    
    var body: some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            self.ImageCaptionView(width: w, height: h)
        }
        .frame(width: totalWidth * 0.75, height: totalHeight * 0.5, alignment: .center)
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

