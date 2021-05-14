//
//  BlogViewCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 02/01/2021.
//

import SwiftUI

struct BlogViewCarousel: View {
    @EnvironmentObject var mainStates:AppStates
    @StateObject var BAPI:BlogAPI = .init()
    @StateObject var SP:swipeParams = .init()
    @Binding var showBlogs:Bool
    @State var selectedBlog:BlogData = .init()
    @State var selectedImage:UIImage = .stockImage
    @State var showBlog:Bool = false
    let height:CGFloat = totalHeight * 0.65
    let width:CGFloat = totalWidth  * 0.8
    init(showBlogs:Binding<Bool>){
        self._showBlogs = showBlogs
    }
    
    
    var viewingBlogDetails:BlogData?{
        get{
            var res:BlogData? = nil
            if self.SP.swiped < self.BAPI.blogs.count{
//                print("SWIPED : \(self.SP.swiped) \t ")
                res = self.BAPI.blogs[self.SP.swiped]
            }
            return res
        }
    }
    
    func getOffset(_ offset:Int) -> CGFloat{
        var diff = offset - self.SP.swiped
        return diff < 3 ? CGFloat(diff) * 30 : 60
    }
    
    func onChanged(_ value:CGFloat){
        print("value : \(value)")
        if (value < 0 && self.SP.swiped < self.BAPI.blogs.count - 1) || (value > 0 && self.SP.swiped > 0){
            self.SP.extraOffset = value
        }
    }
    
    func onEnded(_ value:CGFloat){
        if value < 0 && abs(value) >= 50 && self.SP.swiped < self.BAPI.blogs.count - 1{
            self.SP.swiped += 1
        }else if value > 0 && abs(value) >= 50 && self.SP.swiped > 0{
            self.SP.swiped -= 1
        }
        self.SP.extraOffset = 0
    }
    
    func getWidth(_ offset:Int) -> CGFloat{
        var diff = offset - self.SP.swiped
        return (1 - (diff < 3 ? CGFloat(diff) * 0.1 : 0.2)) * self.width
    }
    
    func rotationalAngle(_ viewing:Bool) -> Angle{
        var factor = Double(self.SP.extraOffset/self.height)
        var angle:Double = (viewing ? 10 : 0)
        return Angle(degrees: factor * angle)
    }
    
    func heading(w:CGFloat,h:CGFloat) -> some View{
        return HStack{
            TabBarButtons(bindingState: self.$showBlogs)
            MainText(content: "Blogs", fontSize: 30, color: .white, fontWeight: .semibold, style: .heading)
            Spacer()
        }.padding().padding(.top,h*0.05).frame(width: w,height: h * 0.1)
    }

    var body: some View {
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            VStack(alignment:.center,spacing: 25){
                self.heading(w: w, h: h)
                ZStack{
                    ForEach(Array(self.BAPI.blogs.enumerated().reversed()), id:\.offset){_blog in
                        let blog = _blog.element
                        let idx = _blog.offset
                        let viewing = self.SP.swiped == idx
                        let minY = g.frame(in: .global).minY/1000
                        if idx >= self.SP.swiped{
                            BlogCarsouselCard(blog: blog,width:self.getWidth(idx),height:self.height,viewing: viewing)
                                .offset(y: self.getOffset(idx))
                                .gesture(DragGesture()
                                            .onChanged({ (value) in
                                                withAnimation(.default) {
                                                    self.onChanged(value.translation.height)
                                                }
                                            })
                                            .onEnded({ (value) in
                                                withAnimation(.default) {
                                                    self.onEnded(value.translation.height)
                                                }
                                            })
                                )
                                .offset(y: viewing ? self.SP.extraOffset : 0)
                                .rotation3DEffect(self.rotationalAngle(viewing), axis: (x: 10, y: 0, z: 0))

                        }
                    }
                }.frame(width: w, height: h * 0.65, alignment: .center)
                
                Spacer()
                if self.viewingBlogDetails != nil{
                        Button {
                            self.showBlog.toggle()
                            self.selectedBlog = self.viewingBlogDetails!
                            self.selectedImage = UIImage.loadImageFromCache(self.selectedBlog.image?.first)
                        } label: {
                            MainText(content: "Read Blog", fontSize: 15, color: .white, fontWeight: .medium)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 25).fill(Color.black))
                        }
                }
                Spacer()
            }
            NavigationLink(destination: LargeBlogCard(blog: self.selectedBlog, firstImage: self.selectedImage,showBlogPost: self.$showBlog), isActive: $showBlog) {
                Text("BlogView")
            }.hidden()
            .navigationTitle("")
            .navigationBarHidden(true)
            
        }.frame(width: totalWidth, height: totalHeight)
        .background(ZStack{
            var image = UIImage.loadImageFromCache(self.viewingBlogDetails?.image?.first) ?? UIImage(named: "AttractionStockImage")!
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
            BlurView(style: .regular)
                .aspectRatio(contentMode: .fill)
            
        }.edgesIgnoringSafeArea(.vertical))
        .onAppear {
            if self.BAPI.blogs.isEmpty{
                self.BAPI.getTopBlogs()
            }
        }
        .onReceive(self.BAPI.$blogs) { (blogs) in
            print("DEBUG MESSAGE : blogs.count == \(blogs.count)")
        }
    }
}

struct BlogCarsouselCard:View{
    var blog:BlogData
    var width:CGFloat
    var height:CGFloat
    var viewing:Bool
    @StateObject var IMD:ImageDownloader = .init()
    var body: some View{
        ZStack{
            Image(uiImage: self.IMD.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height, alignment: .center)
                .overlay(ZStack{
                    if self.viewing{
                        bottomShadow
                    }
                    
                    VStack(alignment:.leading){
                        HStack{
                            Spacer()
                        }
                        Spacer()
                        MainText(content: self.blog.headline?.removeEndLine() ?? "", fontSize: 25, color: .white, fontWeight: .bold, style: .normal)
                        MainText(content: self.blog.summaryText ?? "", fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
                    }.padding().padding(.bottom,50)
                    
                })
            
            if !self.viewing{
                BlurView(style:.regular)
                    .frame(width:self.width,height:self.height)
            }
        }.clipShape(ArcCorners(corner: .topRight, curveFactor: 0.1, cornerRadius: 30, roundedCorner: .allCorners)).frame(width:self.width,height:self.height)
        .onAppear {
            if let imgURL = self.blog.image?.first, self.IMD.url != imgURL{
                self.IMD.getImage(url: imgURL)
            }
        }
        
    }
}

//
//struct BlogViewCarousel_Previews: PreviewProvider {
//    static var previews: some View {
//        BlogViewCarousel()
//    }
//}
