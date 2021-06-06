//
//  ImageView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 05/04/2021.
//

import SwiftUI

struct ImageView:View{
    @EnvironmentObject var mainStates:AppStates
    @StateObject var IMD:ImageDownloader = .init()
    var url:String = ""
    var width:CGFloat
    var height:CGFloat
    var contentMode:ContentMode
    var img:UIImage? = nil
    var autoHeight:Bool = false
    var heading:String? = nil
    var alignment:Alignment
    var isPost:Bool
    var headingSize:CGFloat
    
    
    init(url:String?,heading:String? = nil,width:CGFloat = 300,height:CGFloat = 300,contentMode:ContentMode = .fill,alignment:Alignment = .center,autoHeight:Bool = false,isPost:Bool = false,headingSize:CGFloat = 35){
        self.url = url ?? ""
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.autoHeight = autoHeight
        self.heading = heading
        self.alignment = alignment
        self.isPost = isPost
        self.headingSize = headingSize
    }
    
    
    init(img:UIImage? = nil,width:CGFloat = 300,height:CGFloat = 300,contentMode:ContentMode = .fill,alignment:Alignment = .center,isPost:Bool = false,headingSize:CGFloat = 35){
        self.img = img
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.alignment = alignment
        self.isPost = isPost
        self.headingSize = headingSize
    }
    
    func onAppear(){
        if self.img == nil && self.url != "" && !self.mainStates.testMode{
            self.IMD.getImage(url: self.url,bounds: .init(width: self.width, height: self.height))
        }
    }
    
    func imgView(w _w:CGFloat? = nil,h _h:CGFloat? = nil) -> some View{
        let img = (self.img != nil ? self.img! : self.IMD.image)
        let ar = UIImage.aspectRatio(img: img)
        var h = self.autoHeight ? self.width/ar : _h == nil ? self.height : _h!
        h = self.autoHeight && h < 250 ? 250 : self.autoHeight && h > 350 ? 350 : h
        return ZStack(alignment: .center) {
            Image(uiImage: img)
                .resizable()
                .aspectRatio(ar,contentMode: self.contentMode)
            if self.IMD.loading && self.img == nil{
                Color.black
                BlurView(style: .regular)
            }
            if self.heading != nil{
                lightbottomShadow.frame(width: self.width, height:h, alignment: .center)
                self.overlayView(h: h)
            }
        }.frame(width: self.width,height: h)
        .onAppear(perform: self.onAppear)
    }
    
    func overlayView(h : CGFloat) -> some View{
        return
            GeometryReader{g in
                let w = g.frame(in: .local).width
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    MainText(content: self.heading!, fontSize: self.headingSize, color: .white, fontWeight: .regular)
                    if self.isPost{
                        self.buttons(w: w, h: h)
                    }
                }
            }.padding().frame(width: self.width, height: h, alignment: .center)
    }
    
    
    func buttons(w:CGFloat,h:CGFloat) -> some View{
        let size:CGSize = .init(width: self.width > totalWidth * 0.5 ? 20 : 10, height: self.width > totalWidth * 0.5 ? 20 : 10)
        return VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 20).frame(width: w, height: 2, alignment: .center).foregroundColor(.white.opacity(0.35))
            HStack(alignment: .center, spacing: 25) {
                SystemButton(b_name: "hand.thumbsup", b_content: "\(10)", color: .white,haveBG: false,size: size,bgcolor: .white) {
                    print("pressed Like")
                }
                SystemButton(b_name: "bubble.left", b_content: "\(5)", color: .white,haveBG: false,size: size,bgcolor: .white) {
                    print("pressed Comment")
                }
                Spacer()
            }.padding(.leading,10)
        }
    }
    
    var body: some View{
//        ZStack{
        self.imgView()
            .contentShape(RoundedRectangle(cornerRadius: 10))
//        }
        
    }
    
}
//
//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView()
//    }
//}
