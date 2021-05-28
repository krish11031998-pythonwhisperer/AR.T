//
//  StickyHeaderImage.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 03/02/2021.
//

import SwiftUI

struct StickyHeaderImage: View {
    @StateObject var IMD:ImageDownloader = .init()
    var image:UIImage? = nil
    var img_url:String? = nil
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    var animation:Namespace.ID? = .none
    var curvedCorner:Bool
    @Namespace var  defaultNameSpace
    //    var overlayView:View
    var id:String? = nil
    init(w:CGFloat, h:CGFloat,url:String? = nil, image:UIImage? = nil, namespace:Namespace.ID? = .none, aid:String? = .none, curvedCorner:Bool = true){
        self.img_url = url
        self.width = w
        self.height = h
        self.image = image
        self.animation = namespace
        self.id = aid
        self.curvedCorner = curvedCorner
    }
    
    

    var body: some View {
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let minY = g.frame(in: .global).minY
            let img = self.image != nil ? self.image! : self.IMD.image
            let imgHeight = minY > 0 ? h + minY : h
            let y_off = -((minY > 0 ? minY : 0) + 20)
            let curve = self.curvedCorner ? 30 : 0
            
            ImageView(img: img, width: w, height: imgHeight, contentMode: .fill)
                .clipShape(Corners(rect:[.bottomLeft,.bottomRight],size: .init(width: curve, height:curve)))
//                .matchedGeometryEffect(id: self.id, in: self.animation)
                .offset(y: y_off)
            
        }.frame(width: self.width, alignment: .center)
        .frame(minHeight: self.height)
        .onAppear {
            guard let url = self.img_url, self.IMD.url != url else {return}
            self.IMD.getImage(url: url)
        }
        
        
    }
}

