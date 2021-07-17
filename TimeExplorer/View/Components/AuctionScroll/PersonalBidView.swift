//
//  PersonalBidView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 19/06/2021.
//

import SwiftUI

struct PersonalBidView: View {
    var data:[AVSData]
    var cardSize:CGSize = .init(width: totalWidth, height: totalHeight * 0.5)
    init(data:[AVSData]){
        self.data = data
    }
    
    func secondaryBids(data:[AVSData],w:CGFloat,h:CGFloat) -> some View{
        GeometryReader {g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
        
            HStack(alignment: .center, spacing: 10){
                ForEach(Array(data.enumerated()), id: \.offset) { _data in
                    let data = _data.element
//                    let idx = _data.offset
                    ImageView(url: data.img, width: w * 0.33 - 5, height: h, contentMode: .fill, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .frame(width: w, height: h, alignment: .center)
    }
    
    var body: some View {
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let first = self.data.first ?? .init()
            VStack(alignment: .leading,spacing: 10){
                MainText(content: "Your Bids", fontSize: 25, color: .white, fontWeight: .semibold)
                ImageView(url: first.img, width: w, height: h * 0.5, contentMode: .fill, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                self.secondaryBids(data: Array(self.data[1...]), w: w, h: h * 0.4 - 10)
            }
        }.padding()
        .frame(width: self.cardSize.width, height: self.cardSize.height, alignment: .leading)
        
        
    }
}

struct PersonalBidView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalBidView(data: .init(repeating: .init(img: test.thumbnail, title: test.title, subtitle: test.painterName, data: test), count: 4))
    }
}
