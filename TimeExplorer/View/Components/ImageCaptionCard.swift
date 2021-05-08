//
//  ImageCaptionCard.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 06/04/2021.
//

import SwiftUI


struct ImageCaptionCardData{
    var headline:String?
    var subHeadline:String?
    var _img:UIImage?
    var img_url:String?
    var data:Any
    
}


struct ImageCaptionCard: View {
    
    var cardData:ImageCaptionCardData
    var w:CGFloat
    var h:CGFloat
    var img:UIImage?
    init(_ data:ImageCaptionCardData,w:CGFloat,h:CGFloat,img:UIImage? = nil){
        self.cardData = data
        self.w = w
        self.h = h
        self.img = img
    }
    
    var body: some View {
        let url = self.cardData.img_url ?? ""
        return
            GeometryReader{g in
                let w = g.frame(in: .local).width
                let h = g.frame(in: .local).height
                
                VStack(alignment: .center, spacing: 0){
                    if self.img != nil{
                        ImageView(img: self.img!, width: w, height: h * 0.7, contentMode: .fill)
                    }else{
                        ImageView(url: url, width: w, height: h * 0.7, contentMode: .fill)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        MainText(content: cardData.subHeadline ?? "tripster", fontSize: 15, color: .gray, fontWeight: .semibold, style: .normal).padding(.leading).frame(width: w,alignment: .leading)
                        MainText(content: cardData.headline ?? "headline", fontSize: 15, color: .black, fontWeight: .semibold, style: .normal).padding(.leading).frame(width: w,alignment: .leading)
                    }.padding().frame(width: w,height:h*0.3)
                    .background(Color.white)
                }.frame(width: w, height: h).clipShape(RoundedRectangle(cornerRadius: 25.0))
                
            }.padding(10).frame(width: w, height: h, alignment: .center)
    }
}
//
struct ImageCaptionCard_Previews: PreviewProvider {
    static var previews: some View {
        ImageCaptionCard(.init(headline: "krish.Venkat", subHeadline: "krish", _img: .stockImage, data: Date() as Any), w: 400, h: 400)
    }
}
