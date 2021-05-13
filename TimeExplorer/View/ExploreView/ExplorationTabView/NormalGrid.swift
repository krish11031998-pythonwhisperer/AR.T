//
//  NormalGrid.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 01/04/2021.
//

import SwiftUI

struct NormalGrid:View{
    var data:[ExploreData] = .init()
    @StateObject var IMD:ImageDownloader = .init()
    init(data:[ExploreData]){
        self.data = data
    }
    var body: some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let img = self.data
            LazyHStack{
                ForEach(Array(img.enumerated()),id: \.offset){_data in
                    let data = _data.element
                    let width = w * 0.325
//                    
                    ExploreColCard(data: data, selectedCard: .constant(.init()), showSelectedCard: .constant(false), w: w * 0.325, h: h)
//                    LazyVStack{
//                        MainText(content: "heading", fontSize: 12, color: .black, fontWeight: .regular)
//                            .padding()
//                            .frame(width: width, alignment: .leading)
//                        ImageView(url: data.img, width: w * 0.325, height: h * 0.85, contentMode: .fill)
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                    }
                    
                }
            }
            
        }.padding(10).frame(width: totalWidth, height: totalHeight * 0.2, alignment: .center)
        
    }
    
    
    
}
