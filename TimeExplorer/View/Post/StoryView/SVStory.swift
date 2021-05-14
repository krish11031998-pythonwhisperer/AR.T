//
//  SVMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/9/20.
//

import SwiftUI

struct StoryView: View {
    @StateObject var IMD:ImageDownloader = .init()
    @StateObject var SP:swipeParams = .init()
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var showCaption:Bool = false
    @State var _time:Int = 1
    @Binding var show:Bool
    @EnvironmentObject var mainStates:AppStates
//    @Binding var showTab:Bool
//    var images:[IPDNode] = []
    var images:[PostData] = []
    let timeSpan:Int = 10
    
    func instaFeaturesButtons(imageName:String,count:Int,color:Color) -> some View{
        return HStack {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundColor(color)
            MainText(content: "\(count)", fontSize: 10,color:color)
        }.padding()
    }
    
    func buttons(likes:Int,comments:Int) -> some View{
        return HStack(spacing: 10){
            self.instaFeaturesButtons(imageName: "heart.fill", count: Int(likes), color: Color.red)
            self.instaFeaturesButtons(imageName: "message.fill", count: comments, color: Color.purple)
        }
    }
    
    func storyButton(color:Color,h:CGFloat,action:@escaping () -> Void) -> some View{
        return Rectangle()
            .fill(color.opacity(0.3))
            .frame(height: h, alignment: .center)
            .aspectRatio(contentMode: .fill)
            .onTapGesture {
                action()
            }
    }

    func _image(caption:String,image:UIImage,aR:CGFloat,likes:Int,comments:Int) -> some View{
        var width:CGFloat = totalWidth - 50
        var height:CGFloat = totalHeight - 150
        return GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            
            ZStack(alignment:.center){
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(aR,contentMode: .fill)
                    .frame(width:totalWidth,height:totalHeight + 10)
                BlurView(style: .regular)
                    .aspectRatio(contentMode: .fill)
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(aR,contentMode: .fill)
                    .frame(width:w - 50,height: h - 150)
                    .cornerRadius(25)
                ZStack {
                    Color.black.opacity(0.5).aspectRatio(UIImage.aspectRatio(img: self.IMD.image),contentMode: .fill)
                        .frame(width:totalWidth,height:totalHeight)
                    VStack(alignment:.leading){
                        Spacer().frame(height: totalHeight * 0.65)
                        ScrollView(.vertical,showsIndicators:false){
//                                self.buttons(likes:likes,comments:comments).frame(alignment: .leading)
                            HStack{
                                MainText(content: caption, fontSize: 15, color: .white, fontWeight: .regular).frame(alignment:.leading)
                                Spacer()
                            }.padding(.horizontal)
                            
                            Spacer().frame(height: 100)
                        }.padding().background(BlurView(style: .systemThinMaterialDark).clipShape(RoundedRectangle(cornerRadius: 25)))
                        .padding(10)
                        Spacer().frame(height: 25)
                    }.animation(.spring())
                }.opacity(self.showCaption ? 1 : 0).animation(.spring())
                
                HStack(spacing:0 ){
                    self.storyButton(color: Color.white, h: h) {
                        if self.SP.swiped > 0{
                            self.SP.swiped -= 1
                            self._time = 1
                        }
                    }
                    self.storyButton(color: Color.orange, h: h) {
                        self.showCaption.toggle()
                    }
                    self.storyButton(color: Color.red, h: h) {
                        if self.SP.swiped < self.images.count - 1{
                            self.SP.swiped += 1
                            self._time = 1
                        }
                    }
                    
                }.frame(width: w, height: h, alignment: .center)
                
            }.frame(width: w, height: h, alignment: .center).edgesIgnoringSafeArea(.all)
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)

    }
    
    func checkTimer(){
        var max = self.images.count - 1
        if self._time == timeSpan {
//            if self.SP.swiped < max{
//                self.SP.swiped += 1
//            }else{
//                self.show.toggle()
//                self.mainStates.showTab.toggle()
//            }
            self._time = 1
        }else{
            self._time += 1
        }
        print("time : \(self._time)")
        
    }

    
    func mainImageView() -> some View{
        var image = self.images[self.SP.swiped]
        var img:UIImage = .stockImage
        if let imgURL = image.image?.first , let _img = self.IMD.images[imgURL]{
            img = _img
        }
        
        return self._image(caption: image.caption, image: img, aR: img.aspectRatio(),likes:image.likes ?? 0,comments: image.comments?.count ?? 0)
            
    }
    
    var tabWidth:CGFloat{
        get{
            return (totalWidth - 100)/CGFloat(self.images.count + 1)
        }
    }
    
    func timerTab() -> CGFloat{
//        var time = CGFloat(self._time - (self.SP.swiped * self.timeSpan))
//        return (time * tabWidth * 2)/10.0
        return (CGFloat(self._time) * tabWidth * 2)/CGFloat(10.0)
    }
    
    var tabIcon:some View{
        HStack{
            ForEach(0..<self.images.count){i in
                if i == self.SP.swiped{
                    ZStack(alignment: .leading){
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.35))
                            .frame(width: tabWidth*2,height:10).animation(.easeInOut)
                        
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .frame(width: self.timerTab(),height:10).animation(.easeInOut)
                    }
                }else{
                    Circle()
                        .fill(Color.gray.opacity(0.75))
                        .frame(width: tabWidth,height:10).animation(.easeInOut)
                }
            }.animation(.easeInOut)
        }.frame(width: totalWidth).padding(.horizontal).background(Image("topBackground").resizable().aspectRatio(contentMode: .fill).frame(width:totalWidth,height:120)).animation(.easeInOut)
    }
    
    func onEnded(width:CGFloat,height:CGFloat){
        print("width: \(width) and height: \(height)")
        var testWidth = width > 0 ? width : -width
        var testHeight = height > 0 ? height : -height
        if testWidth > testHeight{
            if width > 0{
                if width > 75 && self.SP.swiped != 0{
                    self.SP.swiped -= 1
                }
            }else if width < 0{
                if -width > 75 && self.SP.swiped != self.images.count - 1{
                    self.SP.swiped += 1
                }
            }
            self.SP.extraOffset = 0
            self._time = 0
        }else if testHeight > testWidth{
            if height > 0 {
                self._time = 0
                self.timer.eraseToAnyPublisher()
                self.show.toggle()
                self.mainStates.showTab.toggle()
            }
        }
        
    }
    
    func onChanged(width:CGFloat,height:CGFloat){
        print("width: \(width) and height: \(height)")
        var testWidth = width > 0 ? width : -width
        var testHeight = height > 0 ? height : -height
        if  testWidth > testHeight && (self.SP.swiped > 0 || self.SP.swiped < self.images.count - 1){
            self.SP.extraOffset = width
        }else if testHeight > testWidth{
            if testHeight < totalHeight/2{
                self.SP.yOffset = testHeight
            }
        }
    }
    
    var body: some View {
        ZStack(alignment:.top){
            self.mainImageView()
            VStack{
                Spacer().frame(height: 50)
                self.tabIcon
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all)
        .onAppear {
            self.IMD.getImages(urls: self.images.compactMap({$0.image?.first}))
        }
        .onReceive(timer){ _ in
//            checkTimer()
            var max = self.images.count - 1
            if self._time == timeSpan {
                if self.SP.swiped < max{
                    self.SP.swiped += 1
                }else{
                    self.show.toggle()
                    self.mainStates.showTab.toggle()
                }
                self._time = 1
            }else{
                self._time += 1
            }
            print("time : \(self._time)")
            
        }
    }
}
