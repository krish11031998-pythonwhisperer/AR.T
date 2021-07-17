//
//  BlogViewMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 04/02/2021.
//

import SwiftUI

struct TabBlogViewMain: View {
    @EnvironmentObject var mainState:AppStates
    @Binding var TabStates:Bool
    @StateObject var BAPI:BlogAPI = .init()
    @State var selectedBlog:BlogData = .init()
    @State var showBlog:Bool = false
//    let width:CGFloat = totalWidth
    @Namespace var animation
    @Binding var showBlogs:Bool
    init(tabstate:Binding<Bool> = .constant(false),show:Binding<Bool> = .constant(false)){
        self._TabStates = tabstate
        self._showBlogs = show
    }
    func onAppear(){
//        if !self.mainState.showTab{
//            self.mainState.showTab = true
//        }
        if self.BAPI.blogs.isEmpty{
            self.BAPI.getTopBlogs(limit: -1)
        }
    }
    
    func onReceive(blogs:[BlogData]){
//        print("DEBUG MESSAGE : blogs.count == \(blogs.count)")
//        self.mainState.loading = false
    }
    
    func scrollView(width:CGFloat) -> some View{
        ScrollView(.vertical, showsIndicators: false) {
            HStack{
                MainText(content: "Blogs", fontSize: 40, color: .black, fontWeight: .semibold, style: .heading)
                Spacer()
            }.padding(15).padding(.top,50)
            TopBlog(blog: self.BAPI.blogs.first ?? .init(), selectedBlog: $selectedBlog, showBlog: $showBlog, width: width, height: totalHeight * 0.4, animation: self.animation)
            TrendingBlogs(blogs: self.BAPI.blogs, selectedBlog: $selectedBlog, showBlog: $showBlog, width: width, height: totalHeight * 0.8)
            BlogVerticalList(blogs: self.BAPI.blogs, selectedBlog: $selectedBlog, showBlog: $showBlog)
        }
    }
    
    
    var body:some View{
        var width = totalWidth - 20
        ZStack {
            if !self.BAPI.blogs.isEmpty{
                self.scrollView(width: width)
            }
            if self.BAPI.blogs.isEmpty{
                BlurView(style: .regular)
                LoadingView()
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .background(Color.yellow)
        .onAppear(perform: self.onAppear)
        .onReceive(self.BAPI.$blogs,perform:self.onReceive)
    }

}

struct TopBlog:View{
    var blog:BlogData
    @StateObject var IMD:ImageDownloader = .init()
    @Binding var selectedBlog:BlogData
    @Binding var showBlog:Bool
    var animation : Namespace.ID
    var isTop:Bool
    var width:CGFloat
    var height:CGFloat
    var idx:Int
    @Binding var expandTab:Bool
    @Namespace var idle
    
    init(blog:BlogData,selectedBlog:Binding<BlogData>,showBlog:Binding<Bool>,width w:CGFloat, height h:CGFloat,animation: Namespace.ID, isTop:Bool = true, idx:Int = -1,expandTab:Binding<Bool>? = nil){
        self.blog = blog
        self._selectedBlog = selectedBlog
        self._showBlog = showBlog
        self.width = w
        self.height = h
        self.isTop = isTop
        self.animation = animation
        self.idx = idx
        if let et = expandTab{
            self._expandTab = et
        }else{
            self._expandTab = Binding.constant(false)
        }
    }
    
    
    
    var card: some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let img = self.IMD.image ?? .stockImage
            ZStack(alignment: .top) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(img.aspectRatio(),contentMode: .fill)
                    .frame(width: w, height: h, alignment: .center)
                    
                    
                lightbottomShadow
                VStack(alignment: .leading, spacing: 10) {
                    HStack{
                        Spacer()
                    }
                    Spacer()
                    MainText(content: self.blog.user ?? "", fontSize: 15, color: .gray, fontWeight: .semibold, style: .normal)
                    MainText(content: self.blog.headline ?? "", fontSize: 20, color: .white, fontWeight: .bold, style: .normal)
                }
                .padding().frame(width: w, height: h, alignment: .center)
                
            }
            .padding().frame(width: w, height: h, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 30))
        }.padding()
        .frame(width: self.width, height: self.height, alignment: .center)
        .onAppear{
            if let url = self.blog.image?.first, self.IMD.url != url{
                self.IMD.getImage(url: url)
            }
        }
    }
    
    var body: some View{
        VStack(alignment: .leading, spacing: 5) {
            MainText(content: isTop ? "Top Blog" : "", fontSize: 35, color: .gray, fontWeight: .semibold, style: .normal)
                .padding(.leading,15)
            self.card
        }
    }
}

//struct TrendingBlogs:View{
//    var blogs:[BlogData]
//    @StateObject var IMD:ImageDownloader = .init()
//    @Binding var selectedBlog:BlogData
//    @Binding var showBlog:Bool
//    var width:CGFloat
//    var height:CGFloat
//    @State var expand:Bool = false
//    @State var tabNum:Int = 0
//    @State var time:Int = 0
//    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    @Namespace var animation
//    @State var expandTab:Bool = false
//    
//    init(blogs:[BlogData],selectedBlog:Binding<BlogData>,showBlog:Binding<Bool>,width w:CGFloat, height h:CGFloat){
//        self.blogs = blogs
//        self._selectedBlog = selectedBlog
//        self._showBlog = showBlog
//        self.width = w
//        self.height = h
//    }
//    
//    var TrendingTabView:some View{
//        VStack(alignment: .center, spacing: 10) {
//            HStack{
//                Spacer()
//                ForEach(0..<5){ i in
//                    let fontColor = self.tabNum == i ? Color.white : Color.black
//                    let bgColor = self.tabNum == i ? Color.black : Color.white
//                    MainText(content: "\(i+1)", fontSize: 12, color: fontColor ,fontWeight: .regular, style: .normal)
//                        .padding()
//                        .background(Circle().fill(bgColor))
//                        .matchedGeometryEffect(id: "number-\(i)", in: self.animation,isSource: !expandTab)
//                }.onTapGesture {
//                    withAnimation(.easeInOut) {
//                        self.expandTab.toggle()
//                    }
//                }
//                Spacer()
//            }.padding(.top,5)
//            
//            GeometryReader{g in
//                var w = g.frame(in: .local).width
//                var h = g.frame(in: .local).height
//                HStack{
//                    Spacer()
//                    TabView(selection: self.$tabNum) {
//                        ForEach(Array(self.blogs.enumerated()),id: \.offset){b in
//                            let blog = b.element
//                            let idx = b.offset
//                            var image = self.IMD.images[blog.image?.first ?? ""] ?? .stockImage
//                            if idx < 5{
//                                ImageCaptionCard(.init(headline: blog.headline, subHeadline: blog.user, img_url: blog.image?.first, data: blog), w: w, h: h,img: image)
//                                .tag(idx)
//                            }
//                        }
//                    }.frame(width: w, height: h, alignment: .center).cornerRadius(30)
//
//                    Spacer()
//                }
//                
//                
//            }.padding(10).frame(width: self.width, height: self.height * 0.4, alignment: .center)
//
//        }.animation(.easeInOut)
//    }
//    
//    
//    func TrendingListCard(blog:BlogData,idx:Int,width:CGFloat,height:CGFloat) -> some View{
//        var img = self.IMD.images[blog.image?.first ?? ""] ?? .stockImage
//        return GeometryReader{g in
//            var w = g.frame(in: .local).width
//            var h = g.frame(in: .local).height
//            let img_url = blog.image?.first ?? ""
//            var id = blog.id ?? ""
//            HStack(alignment: .top, spacing: 5){
//                HStack(alignment: .top, spacing: 10) {
//                    MainText(content: "\(idx+1)", fontSize: 12, color: .white, fontWeight: .regular, style: .normal)
//                        .padding()
//                        .background(Circle().fill(Color.black))
//                        .matchedGeometryEffect(id: "number-\(idx)", in: self.animation,isSource: !expandTab)
//                        
//                    
//                    VStack(alignment: .leading, spacing: 5) {
//                        MainText(content: blog.user ?? "Tripster", fontSize: 15, color: .gray, fontWeight: .bold, style: .normal)
//                        MainText(content: blog.headline?.removeEndLine() ?? "headline", fontSize: 17, color: .black, fontWeight: .semibold, style: .normal)
//                        Spacer(minLength: 0)
//                    }
//                }.frame(height: h, alignment: .center)
//                Spacer()
//                Image(uiImage: img)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: h, height: h , alignment: .top)
//                    .cornerRadius(30)
//                    
//            }.padding()
//            .frame(width: w, height: h, alignment: .center)
//        }.padding(10).frame(width: width, height: height, alignment: .center)
//    }
//    
//    func TrendingCardList(startidx i:Int, endidx j:Int, width w: CGFloat, height h:CGFloat) -> some View{
//        
//        return GeometryReader{g in
//            var _w = g.frame(in:.local).width
//            var _h = g.frame(in: .local).height
//            VStack(alignment: .leading, spacing: 0) {
//                var blogs = Array(self.blogs.enumerated())
//                ForEach(blogs,id:\.offset){_blog in
//                    let blog = _blog.element
//                    let idx = _blog.offset
//                    var cardheight = (_h * 0.25)
//                    let img:UIImage = self.IMD.images[blog.image?.first ?? ""] ?? .stockImage
//                    if idx >= i && idx < j{
//                        
//                        self.TrendingListCard(blog: blog, idx: idx, width: _w, height: cardheight)
//                    }
//                    
//                }
//                Spacer(minLength: 0)
//            }
//        }.padding()
//        .frame(width: w, height: h, alignment: .center)
//        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white).shadow(radius: 5))
//    }
//    
//    var TrendingVerticalList:some View{
//        var index = Array(stride(from: 0, to: self.blogs.count, by: 5))
//        return GeometryReader{g in
//            var w = g.frame(in:.local).width
//            var h = g.frame(in:.local).height
//            TabView {
//                ForEach(index, id:\.self){idx in
//                    self.TrendingCardList(startidx: idx, endidx: idx + 4, width: w, height: h)
//                        .tag(idx)
//                }
//            }
//        }.frame(width: self.width,height: self.height, alignment: .center)
//    }
//    
//    var viewMoreButton:some View{
//        Button {
//            self.expandTab.toggle()
//            print("expand Tab is toggled!")
//        } label: {
//            var text = self.expandTab ? "Less" : "More"
//            MainText(content: "View \(text)", fontSize: 15, color: .white, fontWeight: .medium)
//                .padding()
//                .frame(width: self.width * 0.9, alignment: .center)
//                .background(RoundedRectangle(cornerRadius: 30).fill(Color.gray))
//        }
//
//        
//    }
//    
//    var body: some View{
//        VStack(alignment: .center, spacing: 20) {
//            HStack{
//                MainText(content: "Trending Blogs", fontSize: 35, color: .gray, fontWeight: .semibold, style: .normal)
//                Spacer()
//            }.padding(.leading,15)
//            if !self.expandTab{
//                self.TrendingTabView
//            }
//            if self.expandTab{
//                self.TrendingVerticalList
//            }
//            
//            self.viewMoreButton.padding(10)
//        }
//        .onReceive(self.timer) { (time) in
//            if !self.expandTab{
//                self.time += 1
//                if self.time % 5 == 0{
//                    self.tabNum = self.tabNum < 4 ? self.tabNum + 1 : 0
//                }
//            }
//            
//        }
//        .onAppear(perform: {
//            let urls = self.blogs.compactMap({$0.image?.first})
//            self.IMD.getImages(urls: urls)
//        })
//    }
//}

struct BlogVerticalList:View{
    var blogs:[BlogData]
    @Binding var selectedBlog:BlogData
    @Binding var showBlog:Bool
    
    init(blogs:[BlogData],selectedBlog:Binding<BlogData>,showBlog:Binding<Bool>){
        self.blogs = blogs
        self._selectedBlog = selectedBlog
        self._showBlog = showBlog
    }

    
    var body: some View{
        VStack(alignment: .center, spacing: 25) {
            HStack{
                MainText(content: "Recent Blogs", fontSize: 35, color: .gray, fontWeight: .semibold, style: .normal)
                Spacer()
            }.padding(.leading,15)
            
                .padding(.bottom,10)
            ForEach(Array(self.blogs.enumerated()),id:\.offset){ _blog in
                var blog = _blog.element
                var idx = _blog.offset
                
                BlogVerticalListCard(blog: blog)
            }
        }
//        .padding(.horizontal,-10)
//        .background(Color.black)
    }
}

struct BlogVerticalListCard:View{
    var blog:BlogData
    @StateObject var IMD:ImageDownloader = .init()
    var width:CGFloat
    var height:CGFloat
    let thresHeight = totalHeight * 0.6
    let targetHeight = totalHeight * 0.5
    
    init(blog:BlogData,width:CGFloat = totalWidth, height:CGFloat = totalHeight * 0.35){
        self.blog = blog
        self.width = width
        self.height = height
    }
    
    
    func blogCard(minY:CGFloat,percent:CGFloat,imgHeight:CGFloat,contentHeight:CGFloat,width:CGFloat) -> some View{
        return VStack(alignment: .center, spacing: 0) {
            Image(uiImage: self.IMD.image ?? .stockImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: imgHeight, alignment: .center)
            
            
            if minY <= thresHeight{
                VStack(alignment:.leading,spacing:10){
                    HStack{
                        Spacer()
                    }
                    Spacer()
                    MainText(content: blog.user ?? "Tripster", fontSize: 12, color: .gray, fontWeight: .bold)
                    MainText(content: blog.headline?.removeEndLine() ?? "headline", fontSize: 20, color: .black, fontWeight: .medium)
                        .fixedSize(horizontal: false, vertical: true)
                }.padding(10).padding(.bottom,20).frame(width: width, height: contentHeight, alignment: .center).background(Color.white)
                
            }
        }
        .cornerRadius(30 * (0.5 + (percent > 0 && percent < 1 ? percent * 0.5 : percent > 1 ? 0.5 : 0)))
        .shadow(radius: minY <= thresHeight || minY < targetHeight ? 5 : 0)
        .frame(alignment: .center)
    }
    
    var body: some View{
        GeometryReader{g -> AnyView in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let minY = g.frame(in: .global).minY
            
            let percent = 1 - (minY - targetHeight)/(thresHeight - targetHeight)
            let imgHeight = (minY<thresHeight && minY >= targetHeight ? 1 - (0.4 * percent) : minY > thresHeight ? 1 : 0.6) * h
            let contentHeight = (minY<thresHeight && minY >= targetHeight ? (0.4 * percent) : 0.4) * h
            return AnyView(self.blogCard(minY:minY,percent:percent,imgHeight:imgHeight,contentHeight:contentHeight,width:w))
        }
        .frame(width: AppWidth, height: totalHeight * 0.35, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            guard let url = self.blog.image?.first else {return}
            self.IMD.getImage(url: url)
        }
    }
    
    
}

struct TabBlogViewMain_Previews: PreviewProvider {
    static var previews: some View {
        TabBlogViewMain()
    }
}
