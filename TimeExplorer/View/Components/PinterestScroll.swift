//
//  PinterestScroll.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 01/06/2021.
//

import SwiftUI

struct PinterestScroll: View {
    
    var data:[AVSData]
    
    init(data:[AVSData]){
        self.data = data
    }
    
    func singleCol(col_dir:String = "left",width w:CGFloat) -> some View{
        let rem = col_dir == "left" ? 0 : 1
        return VStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.data.enumerated()),id: \.offset) { _card in
                let card = _card.element
                let idx = _card.offset
                
                if idx%2 == rem{
                    PinterestScrollCard(data: card, width: w)
                }
            }
        }
    }
    
    var body: some View {
        let w = totalWidth - 20
        LazyHStack(alignment: .top, spacing: 10) {
            self.singleCol(col_dir: "left", width: (w * 0.5 - 5))
            self.singleCol(col_dir: "right", width: (w * 0.5 - 5))
        }.padding()
        .frame(width: totalWidth, alignment: .center)
    }
}


struct PinterestScrollCard: View{
    
    var data:AVSData
    var width:CGFloat = (totalWidth - 20) * 0.5
    init(data:AVSData,width w:CGFloat? = nil){
        self.data = data
        if let sw = w{
            self.width = sw
        }
    }
    
    var body: some View{
        ZStack(alignment: .bottom) {
            ImageView(url: self.data.img, width: self.width, contentMode: .fill, alignment: .center, autoHeight: true)
            lightbottomShadow
            MainText(content: self.data.title ?? "", fontSize: 13, color: .white, fontWeight: .regular, style: .normal)
                .padding()
                .frame(width: self.width, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: self.width)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
}

//struct PinterestScroll_Previews: PreviewProvider {
//    static var previews: some View {
//        PinterestScroll()
//    }
//}
