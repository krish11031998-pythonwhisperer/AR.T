//
//  FancyGrid.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 01/04/2021.
//

import SwiftUI

struct FancyGrid:View{
    var data:[ExploreData]
    var direction:direction = .left
    @StateObject var IMD:ImageDownloader = .init()
    
    func largeImg(top:ExploreData,w:CGFloat,h:CGFloat) -> some View{
//        return ExploreColCard(data: top, selectedCard: .constant(.init()), showSelectedCard: .constant(false), w: w, h: h)
        return ImageView(url: top.img, width: w, height: h, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func sideVStack(_imgs:[ExploreData],w:CGFloat,h:CGFloat) -> some View{
        return VStack(alignment: .center, spacing: 4) {
            ForEach(Array(_imgs.enumerated()),id:\.offset){ _data in
                let data = _data.element
//                let idx = _data.offset
//                ExploreColCard(data: data, selectedCard: .constant(.init()), showSelectedCard: .constant(false), w: w, h:  h * 0.5)
                ImageView(url: data.img, width: w, height: h * 0.5, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
    
    var body: some View{
        GeometryReader{g in
            let width = g.frame(in: .local).width
            let height = g.frame(in: .local).height
            let top = self.direction == .left ? self.data.first ?? .init() : self.data.last ?? .init()
            let remaining_img = self.data.filter({$0.img != top.img})
            HStack(alignment:.center,spacing:5){
                if self.direction == .left{
                    self.largeImg(top: top, w: width * 0.6, h: height)
                }
                self.sideVStack(_imgs: remaining_img, w: width * 0.4, h: height)
                if self.direction == .right{
                    self.largeImg(top: top, w: width * 0.6, h: height)
                }
                
            }
        }.padding(10).frame(width: totalWidth, height: totalHeight * 0.3, alignment: .leading)
    }
    
}
