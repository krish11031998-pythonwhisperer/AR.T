//
//  ImageView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 05/04/2021.
//

import SwiftUI

struct ImageView:View{
    @EnvironmentObject var mainStates:AppStates
    @State var image:UIImage?
//    @ObservedObject var IMD:ImageDownloader = .init()
    @StateObject var IMD:ImageDownloader = .init(quality: .low)
    var url:String = ""
    var width:CGFloat
    var height:CGFloat
    var contentMode:ContentMode
//    var img:UIImage? = nil
    var autoHeight:Bool = false
    var heading:String? = nil
    var alignment:Alignment
    var isPost:Bool
    var headingSize:CGFloat
    var isHidden:Bool
    let testMode:Bool = false
    init(url:String?,heading:String? = nil,width:CGFloat = 300,height:CGFloat = 300,contentMode:ContentMode = .fill,alignment:Alignment = .center,autoHeight:Bool = false,isPost:Bool = false,headingSize:CGFloat = 35,isHidden:Bool = false){
        self.url = url ?? ""
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.autoHeight = autoHeight
        self.heading = heading
        self.alignment = alignment
        self.isPost = isPost
        self.headingSize = headingSize
        self.isHidden = isHidden
//        if let safeURL = url{
//            self._IMD = StateObject(wrappedValue: ImageDownloader(url: safeURL, mode: "single", quality: .low))
//        }
    }
    
    
    init(img:UIImage? = nil,heading:String? = nil,width:CGFloat = 300,height:CGFloat = 300,contentMode:ContentMode = .fill,alignment:Alignment = .center,autoHeight:Bool = false,isPost:Bool = false,headingSize:CGFloat = 35,isHidden:Bool = false){
//        self.img = img
        self._image = State(wrappedValue: img)
        self.heading = heading
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.alignment = alignment
        self.isPost = isPost
        self.headingSize = headingSize
        self.isHidden = isHidden
//        self.onAppear()
    }
    
    func onAppear(){
        if self.url != "" && self.image == nil && self.IMD.image == nil && !self.IMD.loading{
            print("ImageView onAppear Called")
            self.IMD.getImage(url: url,bounds: .init(width: self.width, height: self.height))
        }
    }
    
//    func onReceive(img:UIImage?){
//        guard let safeImage = img else {return}
//        self.image = safeImage
//
//    }
    
    func imgView(w _w:CGFloat? = nil,h _h:CGFloat? = nil) -> some View{
        let img = (self.image != nil ? self.image : self.IMD.image)
        let loading = self.image != nil ? false : self.IMD.loading
        let ar = UIImage.aspectRatio(img: img)
        var h = self.autoHeight ? self.width/ar : _h == nil ? self.height : _h!
        h = self.autoHeight && h < 250 ? 250 : self.autoHeight && h > 350 ? 350 : h
        return ZStack(alignment: .center) {
                Color.black.aspectRatio(contentMode: .fill)
                BlurView(style: .regular).aspectRatio(contentMode: .fill)
            if let safeImg = img{
                Image(uiImage: safeImg)
                    .resizable()
                    .aspectRatio(ar,contentMode: self.contentMode)
                    .frame(width: self.width,height: h)
                    .scaleEffect(loading ? 1.25 : 1)
                    .opacity(loading ? 0 : 1)
            }
            
            if self.heading != nil{
                lightbottomShadow.frame(width: self.width, height:h, alignment: .center)
                self.overlayView(h: h)
            }
            if self.isHidden && !self.IMD.loading{
                BlurView(style: .regular)
            }
        }.frame(width: self.width,height: h)
//        .onAppear(perform: self.onAppear)
    }
    
    func overlayView(h : CGFloat) -> some View{
        return
            GeometryReader{g in
                let w = g.frame(in: .local).width
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    MainText(content: self.heading!, fontSize: self.headingSize, color: .white, fontWeight: .regular)
                    RoundedRectangle(cornerRadius: 20).frame(width: w, height: 2, alignment: .center).foregroundColor(.white.opacity(0.35))
                    if self.isPost{
                        self.buttons(w: w, h: h)
                    }else{
                        Spacer().frame(height:25)
                    }
                }
            }.padding()
            .frame(width: self.width, height: h, alignment: .center)
    }
    
    
    func buttons(w:CGFloat,h:CGFloat) -> some View{
        let size:CGSize = .init(width: self.width > totalWidth * 0.5 ? 20 : 10, height: self.width > totalWidth * 0.5 ? 20 : 10)
        
        return HStack(alignment: .center, spacing: 25) {
            SystemButton(b_name: "hand.thumbsup", b_content: "\(10)", color: .white,haveBG: false,size: size,bgcolor: .white) {
                print("pressed Like")
            }
            SystemButton(b_name: "bubble.left", b_content: "\(5)", color: .white,haveBG: false,size: size,bgcolor: .white) {
                print("pressed Comment")
            }
            Spacer()
        }.padding(.leading,10)
    }
    
    var body: some View{
        self.imgView()
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onAppear(perform: self.onAppear)
    }
    
}
//
//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView()
//    }
//}
