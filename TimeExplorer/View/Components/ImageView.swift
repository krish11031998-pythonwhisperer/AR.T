//
//  ImageView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 05/04/2021.
//

import SwiftUI

struct ImageView:View{
    @StateObject var IMD:ImageDownloader = .init()
    var url:String = ""
    var width:CGFloat
    var height:CGFloat
    var contentMode:ContentMode
    var testMode:Bool
    var img:UIImage? = nil
    var autoHeight:Bool = false
    var heading:String? = nil
    var alignment:Alignment
    
    
    
    init(url:String?,heading:String? = nil,width:CGFloat = 300,height:CGFloat = 300,contentMode:ContentMode = .fill,alignment:Alignment = .center,_ testMode:Bool = false,autoHeight:Bool = false){
        self.url = url ?? ""
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.testMode = testMode
        self.autoHeight = autoHeight
        self.heading = heading
        self.alignment = alignment
    }
    
    
    init(img:UIImage? = nil,width:CGFloat = 300,height:CGFloat = 300,contentMode:ContentMode = .fill,alignment:Alignment = .center,_ testMode:Bool = false){
        self.img = img
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.testMode = testMode
        self.alignment = alignment
    }
    
    func onAppear(){
        if self.img == nil && self.url != ""{
            self.IMD.getImage(url: self.url)
        }
    }
    
    func imgView(w _w:CGFloat? = nil,h _h:CGFloat? = nil) -> some View{
        let w = _w == nil ? self.width : _w
        var h = _h == nil ? self.height : _h
        let img = (self.img != nil ? self.img! : self.IMD.image).cropToBounds(width: self.width, height: self.height)
        let ar = UIImage.aspectRatio(img: img)
        h = self.autoHeight ? self.width/ar : h
//        h = h < 175 && self.autoHeight ? 175 : h
        return ZStack(alignment: .center) {
            Image(uiImage: img)
                .resizable()
//                .aspectRatio(ar,contentMode: self.contentMode)
                .aspectRatio(contentMode: self.contentMode)
                .frame(width: self.width, height: h, alignment: alignment)
            
            if self.IMD.loading && self.img == nil{
                Color.black
                BlurView(style: .regular)
            }
            
        }.frame(width: self.width,height: h, alignment: alignment)
        .onAppear(perform: self.onAppear)
    }
    
    
    var imgView_w_caption:some View{
        LazyVStack(alignment: .leading, spacing: 0) {
            MainText(content: self.heading!, fontSize: 12, color: .black, fontWeight: .regular)
                .padding()
                .frame(width: self.width, height: self.height * 0.15, alignment: alignment)
            self.imgView(w: self.width, h: self.height * 0.85)
                .clipShape(Corners(rect: .topRight, size: .init(width: 20, height: 20)))
        }.frame(width: width, height: height, alignment: alignment)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
    }
    
    var body: some View{
        ZStack{
            if self.heading != nil{
                self.imgView_w_caption
                    .transition(.opacity)
            }
            
            if self.heading == nil{
                self.imgView()
                    .transition(.opacity)
            }
        }.animation(.default)
        
    }
    
}
//
//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView()
//    }
//}
