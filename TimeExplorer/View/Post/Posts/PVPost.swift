//
//  PVPost.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/19/20.
//

import SwiftUI

//struct PostDataCard:View{
//    @State var post:PostData
//    @State var showCaption:Bool = false
//    @StateObject var IMD:ImageDownloader = .init()
//    @State var loaded:Bool = false
//    @Binding var loadMore:Bool
//    var count:Int
//    var idx:Int
//    let width:CGFloat = totalWidth - 10
//    @EnvironmentObject var mainStates:AppStates
//    let thresHeight:CGFloat = totalHeight * 0.75
//    let targetHeight:CGFloat = totalHeight * 0.6
//    
//    
//    init(post _post:PostData,loadMore:Binding<Bool>,count:Int,idx:Int){
//        self._post = State(initialValue: _post)
//        self._loadMore = loadMore
//        self.count = count
//        self.idx = idx
//    }
//        
//    func loadMore(minY:CGFloat){
//        if self.idx == self.count - 5{
//            if minY <= totalHeight * 0.5{
//                if !self.loadMore{
//                    self.loadMore.toggle()
//                }
//            }
//        }
//    }
//    
//    var body: some View{
//        SinglePostView(post: self.post, callback: { (val) in
//            self.loadMore(minY: val)
//        })
//            .shadow(radius: 10)
//            .padding()
//    }
//}

struct SinglePostView: View {
    var post:PostData
    var loadMore: () -> Void
    init(post:PostData,callback:@escaping () -> Void){
        self.post = post
        self.loadMore = callback
    }
    
    func header(w width:CGFloat,h height:CGFloat) -> some View{
        return GeometryReader{g in
            let w = g.frame(in:.local).width
            let h = g.frame(in: .local).height
                HStack(alignment: .center, spacing: 10){
                    ImageView(url: "", width: w * 0.1, height: h, contentMode: .fill).clipShape(Circle()).shadow(radius: 1)
                    VStack(alignment: .leading, spacing: 1){
                        MainText(content: self.post.user ?? "user123", fontSize: 13, color: .black, fontWeight: .semibold)
                        MainText(content: "Dubai, United Arab Emirates", fontSize: 10, color: .black, fontWeight: .regular)
                    }
                    Spacer()
                }.frame(width: w, height: h, alignment: .center)
            }.padding()
        .frame(width: width, height: height, alignment: .center)
    }
    
    func footer(w width:CGFloat,h height:CGFloat) -> some View{
        
        func button(name:String,value:Int?,w:CGFloat,h:CGFloat) -> some View{
            var valueStr = value != nil ? "\(value!)" : ""
            return HStack(alignment: .center, spacing: 2.5, content: {
                Image(systemName: name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: h * 0.5, alignment: .center)
                MainText(content: valueStr, fontSize: 15,color: .black)
            }).frame(width: w, height: h, alignment: .center).aspectRatio(contentMode: .fit)
            
        }
        
        return GeometryReader{g in
            let w = g.frame(in:.local).width
            let h = g.frame(in: .local).height
            let bw = w * 0.15
            let bh = h
            HStack(alignment: .center, spacing: 10){
                    button(name: "heart", value: self.post.likes ?? 0,w:bw, h:bh)
                    button(name: "message", value: self.post.comments?.count ?? 0,w:bw, h:bh)
                    button(name: "square.and.arrow.up.on.square", value: nil,w:bw, h:bh)
                
                    Spacer()
                }
            }.frame(width: width, height: height, alignment: .center)
    }
    
    
    
    func captionOverlay(w:CGFloat,h:CGFloat) -> some View{
        VStack(alignment: .leading){
            HStack{
                Spacer()
            }
            Spacer()
            MainText(content: self.post.caption, fontSize: 15, color: .white, fontWeight: .regular)
                .padding(10)
                .frame(height: h * 0.1)
                .background(BlurView(style: .systemThinMaterialDark))
                .clipShape(Capsule())
                .padding(10)
        }.padding(10).frame(width: w, height: h * 0.8, alignment: .center)
    }
    
    var body: some View {
        GeometryReader{g -> AnyView in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let minY = g.frame(in: .global).minY
            
            DispatchQueue.main.async {
                if minY <= totalHeight * 0.5{
                    self.loadMore()
                }
            }
            return AnyView(VStack(alignment: .leading, spacing: 10){
                self.header(w: w, h: h * 0.1)
                ImageView(url:self.post.image?.first, width:w,height:h * 0.8,contentMode:.fill,false)
                    .clipShape(RoundedRectangle(cornerRadius: 25)).shadow(radius: 1.5)
                    .overlay(self.captionOverlay(w: w, h: h))
                self.footer(w: w, h: h * 0.1)
            })
            
        }.padding(10).frame(width: totalWidth, height: totalHeight * 0.5, alignment: .center)
        
    }
}
//
//struct PostPreviews:PreviewProvider{
//
//    static var previews: some View{
//        PostDataCard(post: .init(image: nil, video: nil, caption: "Caption", user: "krish.fabre"), loadMore: .constant(false), count: 0, idx: 0)
//    }
//}
