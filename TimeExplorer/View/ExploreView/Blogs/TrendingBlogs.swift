//
//  TrendingBlogs.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 06/04/2021.
//

import SwiftUI

struct TrendingBlogs:View{
    var _blogs:[BlogData]
    @StateObject var BAPI:BlogAPI = .init()
    @StateObject var IMD:ImageDownloader = .init()
    @Binding var selectedBlog:BlogData
    @Binding var showBlog:Bool
    var width:CGFloat
    var height:CGFloat
    @State var expand:Bool = false
    @State var tabNum:Int = 0
    @State var time:Int = 0
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Namespace var animation
    @State var expandTab:Bool = false
    
    init(blogs:[BlogData],selectedBlog:Binding<BlogData>,showBlog:Binding<Bool>,width w:CGFloat, height h:CGFloat){
        self._blogs = blogs
        self._selectedBlog = selectedBlog
        self._showBlog = showBlog
        self.width = w
        self.height = h
    
    }
    
    
    var blogs:[BlogData]{
        get{
            return self._blogs.isEmpty ? self.BAPI.blogs :  self._blogs
        }
    }
    
    func loadImages(){
        let urls = self.blogs.compactMap({$0.image?.first})
        self.IMD.getImages(urls: urls)
    }
    
    var tabNumberView:some View{
        HStack{
            Spacer()
            ForEach(0..<5){ i in
                let fontColor = self.tabNum == i ? Color.white : Color.black
                let bgColor = self.tabNum == i ? Color.black : Color.white
                MainText(content: "\(i+1)", fontSize: 12, color: fontColor ,fontWeight: .regular, style: .normal)
                    .padding()
                    .frame(alignment: .center)
                    .background(Circle().fill(bgColor))
                    .matchedGeometryEffect(id: "number-\(i)", in: self.animation,isSource: !expandTab)
            }.onTapGesture {
                withAnimation(.easeInOut) {
                    self.expandTab.toggle()
                }
            }
            Spacer()
        }.padding(.top,5).aspectRatio(contentMode: .fit).frame(width: width, alignment: .center)
    }
    
    var TrendingTabView:some View{
        VStack(alignment: .center, spacing: 10) {
            self.tabNumberView
            GeometryReader{g in
                var w = g.frame(in: .local).width
                var h = g.frame(in: .local).height
                    TabView(selection: self.$tabNum) {
                        ForEach(Array(self.blogs.enumerated()),id: \.offset){b in
                            let blog = b.element
                            let idx = b.offset
                            var image = self.IMD.images[blog.image?.first ?? ""] ?? .stockImage
                            if idx < 5{
                                ImageCaptionCard(.init(headline: blog.headline, subHeadline: blog.user, img_url: blog.image?.first, data: blog), w: w - 10, h: h,img: image)
                                    .shadow(radius: 5)
                                .tag(idx)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(width: w, height: h, alignment: .center).cornerRadius(30)
            }.padding(10).frame(width: self.width, height: self.height * 0.6, alignment: .center)

        }.animation(.easeInOut)
    }
    
    
    func TrendingListCard(blog:BlogData,idx:Int,width:CGFloat,height:CGFloat) -> some View{
        let img = self.IMD.images[blog.image?.first ?? ""] ?? .stockImage
        return GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            HStack(alignment: .top, spacing: 5){
                HStack(alignment: .top, spacing: 10) {
                    MainText(content: "\(idx+1)", fontSize: 12, color: .white, fontWeight: .regular, style: .normal)
                        .padding()
                        .background(Circle().fill(Color.black))
                        .matchedGeometryEffect(id: "number-\(idx)", in: self.animation,isSource: !expandTab)
                        
                    
                    VStack(alignment: .leading, spacing: 5) {
                        MainText(content: blog.user ?? "Tripster", fontSize: 10, color: .gray, fontWeight: .bold, style: .normal)
                        MainText(content: blog.headline?.removeEndLine() ?? "headline", fontSize: 15, color: .black, fontWeight: .semibold, style: .normal)
                        Spacer(minLength: 0)
                    }
                }.frame(height: h, alignment: .center)
                Spacer()
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: w * 0.3, height: h , alignment: .top)
                    .cornerRadius(30)
            }
            .frame(width: w, height: h, alignment: .center)
        }.padding(10).frame(width: width, height: height, alignment: .center)
    }
    
    func TrendingCardList(startidx i:Int, endidx j:Int, width w: CGFloat, height h:CGFloat) -> some View{
        
        return GeometryReader{g in
            let _w = g.frame(in:.local).width
            let _h = g.frame(in: .local).height
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    self.expandTab.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .padding()
                        .background(BlurView(style: .regular))
                        .clipShape(Circle())
                })
                let blogs = Array(self.blogs.enumerated())
                ForEach(blogs,id:\.offset){_blog in
                    let blog = _blog.element
                    let idx = _blog.offset
                    let cardheight = (_h * 0.175)
                    let img:UIImage = self.IMD.images[blog.image?.first ?? ""] ?? .stockImage
                    if idx >= i && idx < j{
                        self.TrendingListCard(blog: blog, idx: idx, width: _w, height: cardheight)
                    }
                    
                }
                Spacer(minLength: 0)
            }
        }.padding(20)
        .frame(width: w, height: h, alignment: .center)
        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white).shadow(radius: 5))
        .padding(5)
    }
    
    var TrendingVerticalList:some View{
        var step = 5
        let index = Array(stride(from: 0, to: self.blogs.count, by: step))
        return GeometryReader{g in
            let w = g.frame(in:.local).width
            let h = g.frame(in:.local).height
            TabView {
                ForEach(index, id:\.self){idx in
                    self.TrendingCardList(startidx: idx, endidx: idx + step, width: w, height: h)
                        .tag(idx)
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }.frame(width: self.width,height: self.height, alignment: .center)
    }

    
    var body: some View{
        VStack(alignment: .center, spacing: 20) {
            HStack{
                MainText(content: "Trending Blogs", fontSize: 25, color: .black, fontWeight: .bold, style: .normal)
                Spacer()
            }.padding(.leading,15)
            if !self.expandTab{
                self.TrendingTabView
            }
            if self.expandTab{
                self.TrendingVerticalList
            }
            
//            self.viewMoreButton.padding(50)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .padding(.vertical,10)
        .onReceive(self.timer) { (time) in
            if !self.expandTab{
                self.time += 1
                if self.time % 5 == 0{
                    self.tabNum = self.tabNum < 4 ? self.tabNum + 1 : 0
                }
            }
            
        }
        .onAppear(perform: {
            if self.blogs.isEmpty{
                self.BAPI.getTopBlogs(limit: -1)
            }else{
                self.loadImages()
            }
        })
        .onReceive(self.BAPI.$blogs, perform: { _ in
            self.loadImages()
        })
    }
}

struct TrendingBlogs_Previews: PreviewProvider {
    
    static var previews: some View {
        return TrendingBlogs(blogs: [], selectedBlog: .constant(.init()), showBlog: .constant(false), width: AppWidth, height: totalHeight * 0.8)
    }
}
