//
//  BlogMainView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 11/25/20.
//

import SwiftUI

struct BlogMainView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


struct LargeBlogCard:View{
    var blog:BlogData
    var firstImage:UIImage?
    @State var tabNum:Int = 0
    @StateObject var IMD:ImageDownloader = .init()
    @State var mainImgTabHeight:CGFloat = totalHeight
    @State var blogImages:[String] = []
    @EnvironmentObject var mainStates:AppStates
    @Binding var showBlogPost:Bool
    var img_num:Int = 0
    //    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var images:[UIImage]{
        get{
            return Array(self.IMD.images.values)
        }
    }
    
    var readMore:Bool{
        get{
            return self.mainImgTabHeight == totalHeight
        }
    }
    
    
    var imageView:some View{
        Image(uiImage: self.firstImage ?? .stockImage)
            .resizable()
            .aspectRatio(contentMode:.fill)
            .frame(width:totalWidth,height:self.mainImgTabHeight)
            .clipShape(ArcCorners(corner: .bottomRight, curveFactor: !self.readMore ? 0.15 : 0, cornerRadius:50,roundedCorner: [.bottomLeft,.bottomRight]))
            .overlay(
                
                ZStack(alignment:.bottom){
                    VStack{
                        Spacer().frame(height:totalHeight * 0.05)
                        HStack{
                            TabBarButtons(bindingState: self.$showBlogPost).padding().background(Circle().fill(Color.gray.opacity(0.35)))
                            Spacer()
                        }.padding()
                        Spacer()
                    }.background(readMore ? bottomShadow : LinearGradient(gradient: .init(colors: [Color.clear,Color.clear]), startPoint: .top, endPoint: .bottom))
                    if self.readMore{
                        self.mainBody
                    }
                }
            )
    }
    
    func onChanged(value:CGFloat){
        if value < 0{
            self.mainImgTabHeight += value
        }
    }
    
    func onEnded(value:CGFloat){
        if value < 0{
            if abs(value) <= totalHeight * 0.5{
                self.mainImgTabHeight = totalHeight * 0.45
//                self.mainStates.showTab.toggle()
            }
        }
    }
    
    
    var mainBody:some View{
        VStack(alignment:.leading,spacing:15){
            Spacer()
            MainText(content: self.blog.headline ?? "" , fontSize: 25, color: .white, fontWeight: .bold)
            MainText(content: self.blog.summaryText ?? "", fontSize: 15, color: .white, fontWeight: .regular)
            MainText(content: self.blog.location ?? "", fontSize: 15, color: .white, fontWeight: .regular)
            Spacer().frame(height:50)
        }.frame(width: AppWidth,alignment:.leading).padding()
    }
    
    var ArticleText:EnumeratedSequence<[String]>{
        get{
            var result:[String] = []
 
            if let article = self.blog.articleText{
                print(article)
                var temp:[String] = []
                article.components(separatedBy: "\n").enumerated().forEach { (str) in
                    if str.offset%2 == 0 && str.offset != 0{
                        var tempResult = String.stringReducer(str:temp)
                        result.append(tempResult)
                        temp = []
                    }
                    temp.append(str.element)
                }
                if temp.count > 0{
                    result.append(String.stringReducer(str:temp))
                }
                
            }
            print("result: \(result)")
            
            return result.enumerated()
            
        }
    }
    
    func TextArticle(_ str:String,_ i:Int) -> some View{
        var imageNum = i + 1
        var view = VStack{
            MainText(content: str, fontSize: 17.5, color: .black, fontWeight: .regular)
                .fixedSize(horizontal: false, vertical: true)
            if imageNum < self.images.count{
                Image(uiImage: self.images[i + 1])
                    .resizable()
                    .aspectRatio(UIImage.aspectRatio(img:self.images[imageNum]),contentMode: .fill)
                    .frame(width: AppWidth, height: 300, alignment: .center)
                    .cornerRadius(30)
                    .padding(.vertical)
            }

        }
        return view
    }
    
    var horizontalCol = [GridItem.init(.flexible(minimum: 125, maximum: 250)),GridItem.init(.flexible(minimum: 125, maximum: 250))]
    
    var customImageGrid:some View{
        LazyHGrid(rows: horizontalCol, alignment: .top, spacing: 10) {
            ForEach(Array(self.ArticleText).count + 1..<self.images.count){i in
                Image(uiImage: self.images[i])
                    .resizable()
                    .aspectRatio(UIImage.aspectRatio(img: self.images[i]), contentMode: .fit)
                    .cornerRadius(25)
            }
        }
    }
    
    var profileImage:UIImage{
        get{
            let url = self.mainStates.userAcc.user.photoURL
            return UIImage.loadImageFromCache(url) ?? UIImage(named: "AttractionStockImage")!
        }
    }
    
    var nameUser:String{
        get{
            let user = self.mainStates.userAcc.user
            if let fname = user.firstName, let lname = user.lastName{
                return fname + " " + lname
            }
            return ""
        }
    }
    
    func rowImages(_ col:String) -> [UIImage]{
        var start = Array(self.ArticleText).count + 1
        var colImage:[UIImage] = []
        var remin = col == "left" ? 0 : 1
        for x in start..<self.images.count{
            if x%2 == remin{
                colImage.append(self.images[x])
            }
            
        }
        return colImage
    }
    
    func imageRow(_ imgs:[UIImage]) -> some View{
        VStack{
            ForEach(Array(imgs.enumerated()),id: \.offset) { img in
                Image(uiImage: img.element)
                    .resizable()
                    .aspectRatio(UIImage.aspectRatio(img: img.element),contentMode: .fill)
                    .frame(width: AppWidth*0.45)
                    .frame(maxHeight:350)
                    .clipped()
                    .cornerRadius(25)
            }
        }.frame(width: AppWidth*0.5)
    }
    
    var customVGrid:some View{
        HStack(alignment:.top){
            self.imageRow(self.rowImages("left"))
            self.imageRow(self.rowImages("right"))
        }.frame(width:AppWidth)
    }
    
    var blogHeading:some View{
        VStack(alignment:.leading,spacing: 15){
            MainText(content: self.blog.headline?.replacingOccurrences(of: "\n", with: "") ?? "", fontSize: 25, color: .black, fontWeight: .bold)
                .fixedSize(horizontal: false, vertical: true)
            MainText(content: self.blog.summaryText ?? "", fontSize: 15, color: Color.gray.opacity(0.75), fontWeight: .semibold)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .center, spacing: 10) {
                Image(uiImage: self.profileImage)
                    .resizable()
                    .frame(width:30,height: 30)
                    .clipShape(Circle())
                    
                MainText(content: self.nameUser, fontSize: 15, color: .black, fontWeight: .regular)
            }
            MainText(content: self.blog.location ?? "", fontSize: 12.5, color: .black, fontWeight: .regular)
            
        }.frame(width:AppWidth,alignment:.leading)
    }
    
    var blogContent:some View{
        VStack(alignment:.leading,spacing: 15){
            self.blogHeading
            ForEach(Array(self.ArticleText), id:\.offset) { (art) in
                if art.element != ""{
                    self.TextArticle(art.element, art.offset)
                }
            }.padding(.bottom)
            
            if Array(self.ArticleText).count + 1 < self.images.count{
                MainText(content: "More Pictures", fontSize: 25, color: .black, fontWeight: .semibold)
//                ScrollView(.horizontal,showsIndicators:false){
//                    self.customImageGrid
                self.customVGrid
//                }.frame(width:AppWidth).padding(.vertical)
            }
            
            
            Spacer().frame(height: 100)
        }.padding()
    }
    
    var mainHeaderView:some View{
        ZStack(alignment: .top){
            Color.white
            ScrollView{
                self.imageView
                if !self.readMore{
                    self.blogContent
                }
            }.disabled(self.readMore)
            .gesture(DragGesture()
                        .onChanged({ (value) in
                            self.onChanged(value: value.translation.height)
                        })
                        .onEnded({ (value) in
                            self.onEnded(value: value.translation.height)
                        })
            )
            if self.readMore{
                VStack{
                    Spacer().frame(height:totalHeight * 0.05)
                    HStack{
                        TabBarButtons(bindingState: self.$showBlogPost).padding().background(Circle().fill(Color.gray.opacity(0.35)))
                        Spacer()
                    }.padding()
                    Spacer()
                    
                }
            }
        }.animation(.easeInOut)
    }
    
    var body:some View{
        self.mainHeaderView
//            .frame(width:totalWidth,height:totalHeight)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                if let images = self.blog.image , self.IMD.images.isEmpty{
                    IMD.getImages(urls: images.compactMap{$0})
                }
                withAnimation(.easeInOut){
                    self.mainStates.showTab = false
                }
                
            }.animation(.easeInOut)
            .onDisappear{
                if !self.mainStates.showTab && self.mainStates.tab != "feed"{
                    withAnimation(.easeInOut){
                        self.mainStates.showTab = true
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
    }
}


//struct BlogMainView_Previews: PreviewProvider {
//    static var previews: some View {
////        BlogMainView()
//        LargeBlogCard(blog: blogExample)
//    }
//}
