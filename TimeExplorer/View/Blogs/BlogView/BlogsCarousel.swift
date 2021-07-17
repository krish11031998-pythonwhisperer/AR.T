//
//  BlogViewMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 11/22/20.
//
import SwiftUI

struct BlogsCarousel: View {
    @StateObject var SP:swipeParams = .init()
    @StateObject var BAPI:BlogAPI = .init()
    @EnvironmentObject var mainStates:AppStates
    @State var showBlogForm:Bool = false
    @State var selectedBlog:BlogData = .init()
    @State var selectedImage:UIImage = .stockImage
    @State var showBlog:Bool = false
    var width:CGFloat = AppWidth - 75
    var height:CGFloat = totalHeight * 0.6
    
    func cardOffset(_ index:Int) -> CGFloat{
        var diff = abs(self.SP.swiped - index)
        return diff < 3 ? CGFloat(diff)*15.0 : 30.0
    }
    
    func onChanged(value:CGFloat){
        if (value < 0 && self.SP.swiped < BAPI.blogs.count - 1) || (value > 0 && self.SP.swiped > 0){
            self.SP.extraOffset = value
        }
    }
    
    func onEnded(value:CGFloat){
        if value < 0{
            if (self.SP.swiped < self.BAPI.blogs.count - 1) && abs(value) > 35{
                self.SP.swiped += 1
            }
        }else if value > 0{
            if (self.SP.swiped > 0) && abs(value) > 35{
                self.SP.swiped -= 1
            }
        }
        self.SP.extraOffset = 0
    }
    
    func getHeight(_ offset:Int) -> Double{
        var diff = offset - self.SP.swiped
        return 1 - (diff < 3 ? Double(diff) * 0.1 : 0.2)
    }
    
    func rotationalAngle(_ viewing:Bool) -> Angle{
        var rotationalFactor = Double(self.SP.extraOffset/self.height)
        return Angle(degrees: rotationalFactor * (viewing ? 10 : 0))
    }
    
    var blogCardsOverflow:some View{
        ZStack{
            if !self.BAPI.blogs.isEmpty{
                ForEach(self.BAPI.blogs.enumerated().reversed(), id:\.offset) { blog  in
                    var viewing = self.SP.swiped == blog.offset
                    var blogCard = BlogCardMain(blog: blog.element, user: self.mainStates.userAcc.user, width:width,height:CGFloat(self.getHeight(blog.offset)) * self.height, cardViewing: viewing)
                    if  blog.offset >= self.SP.swiped{
                        Button {
                            self.selectedBlog = blog.element
                            self.selectedImage = UIImage.loadImageFromCache(self.selectedBlog.image?.first ?? "")
                            self.showBlog.toggle()
                        } label: {
                            blogCard
                                .offset(x: self.cardOffset(blog.offset))
                                .gesture(DragGesture()
                                            .onChanged({ (Value) in
                                                withAnimation(.easeInOut) {
                                                    self.onChanged(value: Value.translation.width)
                                                }
                                            })
                                            .onEnded({ (Value) in
                                                withAnimation(.easeInOut) {
                                                    self.onEnded(value: Value.translation.width)
                                                }
                                            })
                                )
                                .offset(x: viewing ? self.SP.extraOffset : 0)
                                .rotationEffect(self.rotationalAngle(viewing))
                        }
                    }
                    
                }
            }else{
                MainText(content: "No Blogs Available", fontSize: 15, color: .black, fontWeight: .regular)
            }
            
        }.frame(width: totalWidth, height: totalHeight * 0.6)
    }
    
    var body:some View{
        VStack{
            HStack{
                Spacer()
                Button(action: {
                    print("Adding Blogs")
                    self.showBlogForm.toggle()
                }, label: {
                    MainText(content: "+ Add Blog", fontSize: 12, color: .black, fontWeight: .semibold)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.35)))
                })
            }.padding()
            Spacer()
            self.blogCardsOverflow
            NavigationLink(
                destination: BlogPostView(),
                isActive: self.$showBlogForm,
                label: {
                    Text("Navigate")
                }).hidden()
            NavigationLink(
                destination: LargeBlogCard(blog: self.selectedBlog, firstImage: self.selectedImage,showBlogPost: self.$showBlog),
                isActive: self.$showBlog,
                label: {
                    Text("Navigate")
                }).hidden()
                
            
        }.onAppear{
            if self.BAPI.blogs.isEmpty{
                self.BAPI.getBlogs(user: self.mainStates.userAcc.username)
            }
        }.onReceive(self.BAPI.$blogs) { (blogs) in
            print("Recieved blogs with length : \(blogs.count)")
            if self.BAPI.blogs.count > 0{
                print(self.BAPI.blogs.first!)
            }
        }
    }
}

struct BlogCardMain: View{
    var blog:BlogData
    @StateObject var IMD:ImageDownloader = .init()
//    @Binding var selectedBlog:BlogData
//    @Binding var selectedImage:UIImage
//    @Binding var showBlog:Bool
    var user:User
    var width:CGFloat
    var height:CGFloat
    var cardViewing:Bool
    
//    var profileImage:UIImage{
//        get{
//            if let img_url = self.user.photoURL,let imgData = ImageCache.object(forKey: NSString(string: img_url)) as Data?, let img = UIImage(data: imgData){
//                return img
//            }else{
//                return UIImage(named: "AttractionStockImage")!
//            }
//
//        }
//    }
    var profileImage:UIImage{
        get{
            return UIImage.loadImageFromCache(self.user.photoURL)
        }
    }
    
    var imageOverlayView:some View{
        ZStack{
            VStack(alignment:.leading){
                HStack{
                    Image(uiImage: self.profileImage)
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                    Spacer()
                }
                Spacer()
                VStack(alignment:.leading,spacing:15){
                    MainText(content: String(String(self.blog.headline ?? "").filter { !"\n\t\r".contains($0) }), fontSize: 20, color: .white, fontWeight: .bold)
                    MainText(content: String(String(self.blog.location ?? "").filter { !"\n\t\r".contains($0) }), fontSize: 10, color: .white, fontWeight: .semibold)
                }.padding()
                Spacer().frame(height:50)
            }.padding()
            .background(bottomShadow)
            
             
            if !self.cardViewing{
                BlurView(style: .regular)
            }
            
        }
        
    }

    // "Swift Language"
    
    var mainCard:some View{
        Image(uiImage: self.IMD.image ?? .stockImage)
            .resizable()
            .aspectRatio(UIImage.aspectRatio(img: self.IMD.image),contentMode: .fill)
            .frame(width: self.width, height: self.height, alignment: .center)
            .overlay(
                self.imageOverlayView
            )
//            .cornerRadius(50)
            .clipShape(ArcCorners(corner: .bottomRight, curveFactor: 0.15, cornerRadius: 50))
            .onAppear(perform: {
                print("Reading the new Blog Image")
                guard let firstImage = self.blog.image?.first else {return}
                if self.IMD.url != firstImage{
                    print(firstImage)
                    self.IMD.getImage(url: firstImage)
                }
            })
    }
    
    var body: some View{
//        Button {
//            self.selectedBlog = self.blog
//            self.selectedImage = self.IMD.image
//        } label: {
            self.mainCard
//        }
    }
}


struct BlogViewMain_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            BlogsCarousel()
        }
    }
}
