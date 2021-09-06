//
//  ImageView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 05/04/2021.
//

import SwiftUI

struct ImageView:View{
    @State var image:UIImage?
    @StateObject var IMD:ImageDownloader = .init()
    var url:String?
    var width:CGFloat
    var height:CGFloat
    var contentMode:ContentMode
    var autoHeight:Bool = false
    var heading:String? = nil
    var alignment:Alignment
    var isPost:Bool
    var headingSize:CGFloat
    var isHidden:Bool
    let testMode:Bool = false
    let quality:JPEGQuality
    
    init(img:UIImage? = nil,url:String? = nil,heading:String? = nil,width:CGFloat = 300,height:CGFloat = 300,contentMode:ContentMode = .fill,alignment:Alignment = .center,autoHeight:Bool = false,isPost:Bool = false,headingSize:CGFloat = 35,isHidden:Bool = false,quality:JPEGQuality = .low,isModel:Bool = false){
        self._image = .init(wrappedValue: img)
        self.url = url
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.autoHeight = autoHeight
        self.heading = heading
        self.alignment = alignment
        self.isPost = isPost
        self.headingSize = headingSize
        self.isHidden = isHidden
        self.quality = quality
//        self._IMD = .init(wrappedValue: .init(url: url,quality: quality,isModelURL: isModel))
    }
            
    func img_h(img:UIImage? = nil) -> CGFloat{
        var h = self.height
        if self.autoHeight && img != nil{
            let ar = UIImage.aspectRatio(img: img)
            h = self.width/ar
            h = self.autoHeight && h < 250 ? h * 1.5  : h
        }
        return h
    }
    
    func imgView(w _w:CGFloat? = nil,h _h:CGFloat? = nil) -> some View{
        let img =  self.image ?? self.IMD.image ?? .stockImage
        let loading = self.image != nil ? false : self.IMD.loading
        let h = self.img_h(img: img)
        return ZStack(alignment: .center) {
            
            BlurView(style: .dark)
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: self.contentMode)
                .frame(width: self.width,height: h)
                .scaleEffect(loading ? 1.25 : 1)
                .opacity(loading ? 0 : 1)
            if self.heading != nil{
                lightbottomShadow.frame(width: self.width, height:h, alignment: .center)
                self.overlayView(h: h)
            }
            if self.isHidden && !self.IMD.loading{
                BlurView(style: .regular)
            }
        }.frame(width: self.width,height: h)
        .onAppear {
            if let url = self.url , self.IMD.image == nil{
                self.IMD.getImage(url: url)
            }
        }
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
//            .onAppear(perform: self.onAppear)
    }
    
}
