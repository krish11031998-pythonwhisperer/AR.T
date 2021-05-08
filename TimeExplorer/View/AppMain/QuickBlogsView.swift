//
//  BlogsView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 08/12/2020.
//

import SwiftUI

struct QuickBlogsView: View {
    @StateObject var BlogManager:BlogAPI = .init()
//    @StateObject var IMD:ImageDownloader = .init()
    @State var top4Blogs:[BlogData] = []
    @State var selectedBlog:BlogData = .init()
    @State var showBlog:Bool = false
    @State var tabNum:Int = 0
    var viewMore : () -> Void
    
    init(_ viewMore:@escaping (() -> Void)){
        self.viewMore = viewMore
    }
    
    var TopBlogs:some View{

        GeometryReader{out_g in
            var blogs = Array(self.top4Blogs.enumerated())
            let out_frame = out_g.frame(in: .local)
            var w = out_frame.width
            var h = out_frame.height
            ScrollView(.horizontal,showsIndicators:false){
                HStack(alignment:.center,spacing: 20){
                    ForEach(blogs,id: \.offset){ blogObj in
                        var blog = blogObj.element
                        var idx = blogObj.offset
                        Button {
                            withAnimation(.easeInOut) {
                                self.selectedBlog = blog
                                self.showBlog = true
                            }
                        } label: {
                            BlogCard(blog, w * 0.65, h,idx)
                        }
                    }
                    Button {
                        print("Clicked More")
                        self.viewMore()
                    } label: {
                        VStack{
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                            MainText(content: "More", fontSize: 12, color: .white, fontWeight: .bold)
                        }.padding()
                            .background(Color.gray)
                            .clipShape(Circle())
                    }.padding(.leading,w * 0.2)
                }.padding(.horizontal,10)
            }.frame(width:w,height:h)
        }
    }
    
    var body:some View{
        
        var width:CGFloat = totalWidth
        var height:CGFloat = 400
        VStack(alignment:.center,spacing:10){
            if !self.top4Blogs.isEmpty{
                Group{
                    self.TopBlogs.frame(width: width, height: height, alignment: .center)
                }.frame(alignment: .center)
            }else{
                MainText(content: "No Blogs", fontSize: 15, color: .black, fontWeight: .regular)
            }
            NavigationLink("", destination: LargeBlogCard(blog: self.selectedBlog, firstImage: .loadImageFromCache(self.selectedBlog.image?.first ?? ""), showBlogPost: self.$showBlog), isActive: self.$showBlog).hidden()
                .navigationTitle("")
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .onAppear {
            if self.BlogManager.blogs.isEmpty{
                self.BlogManager.getTopBlogs(limit: 4)
            }
        }
        .onReceive(self.BlogManager.$blogs) { (blogs) in
            if !blogs.isEmpty && blogs.count >= 4{
                let fourblogs = Array(blogs[0...3])
                self.top4Blogs = fourblogs
            }
        }
        .navigationBarHidden(true)
    }
}

struct BlogCard:View{
    var blog:BlogData
    var width:CGFloat
    var height:CGFloat
    var number:Int
    @StateObject var IMD:ImageDownloader = .init()
    var thresWidth:CGFloat = totalWidth * 0.9 * 0.6
    var targetWidth:CGFloat = totalWidth * 0.9 * 0.5
    
    init(_ blog:BlogData,_ width:CGFloat, _ height:CGFloat, _ num:Int){
        self.blog = blog
        self.width = width
        self.height = height
        self.number = num
    }
    
    func cardHeight(_ minX:CGFloat, _ percent:CGFloat, _ type:String, _ h:CGFloat) -> CGFloat{
        let targetHeight = h * (type == "caption" ? 0.3 : 0.7)
        var result:CGFloat = 0
        var factor:CGFloat = 0
        if (minX >= self.thresWidth && minX <= self.targetWidth){
            switch (type){
            case "image":
                factor = 1 - (0.2 * (1 - percent))
            case "caption":
                factor = 0.2 * (1 - percent)
            default:
                break
            }
            result = h * factor
            result = type == "caption" ? result > targetHeight ? targetHeight : result : result < targetHeight ? result : targetHeight
        }
        else if minX <= self.targetWidth{
            result = targetHeight
        }
        else{
            result = type == "caption" ? 0 : h
        }
        return result
    }
    
    var body:some View{
        GeometryReader{g in
            let h = g.frame(in: .local).height
            let w = g.frame(in: .local).width
            let minX = g.frame(in: .global).minX
            let activate = minX <= self.thresWidth
            let percent =  (minX - self.targetWidth)/(self.thresWidth - self.targetWidth)
            let imgHeight = self.cardHeight(minX, percent, "image",h * 0.9)
            let contentHeight = self.cardHeight(minX, percent, "caption",h * 0.9)
            
            ZStack(alignment: .top) {
                
                VStack{
                    ImageView(url: self.blog.image?.first, width: w, height: imgHeight, contentMode: .fill)
                        .clipped()
                    if activate{
                        VStack(alignment: .leading){
                            Spacer()
                            VStack(alignment: .leading, spacing: 10){
                                HStack{
                                    VStack(alignment: .leading, spacing: 10) {
                                        MainText(content: self.blog.user ?? "User", fontSize: 12, color: .gray, fontWeight: .regular)
                                        MainText(content: self.blog.headline ?? "Title", fontSize: 15, color: .black, fontWeight: .semibold)
                                    }
                                    Spacer()
                                    MainText(content: "#\(self.number + 1)", fontSize: 15, color: Color.white, fontWeight: .bold, style: .normal)
                                        .padding()
                                        .background(Circle().fill(Color.black))
                                }
                            }.opacity(Double(1 - percent) * 1).padding(10)
                            Spacer()
                        }.frame(width:w,height:contentHeight).background(Color.white)
                    }
                    
                }.frame(width: w, height: h * 0.9, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }.frame(width: w, height: h, alignment: .center)
            
            
        }
        .frame(width: self.width, height: self.height, alignment: .center)
    }
    
}
