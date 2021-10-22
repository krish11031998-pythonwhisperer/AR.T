//
//  PinterestView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 27/06/2021.
//

import SwiftUI

struct PinterestScroll: View {
    @EnvironmentObject var mainStates:AppStates
    var data:[AVSData]
    var equalSize:Bool
    init(data:[AVSData],equalSize:Bool = false){
        self.data = data
        self.equalSize = equalSize
    }
    
    func singleCol(col_dir:String = "left",width w:CGFloat) -> some View{
        let rem = col_dir == "left" ? 0 : 1
        return VStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.data.enumerated()),id: \.offset) { _card in
                let card = _card.element
                let idx = _card.offset
                
                if idx%2 == rem{
                    PinterestScrollCard(data: card, width: w)
                        .buttonify {
                            self.mainStates.updateSelectedArt(data: card.data)
                        }
                }
            }
        }
    }
    
    
    var CollectionView:some View{
        let w =  (totalWidth - 10) * 0.5 - 15
        let cols = [GridItem.init(.adaptive(minimum: w , maximum: w),spacing: 10)]
        return LazyVGrid(columns: cols, alignment: .center, spacing: 10) {
            ForEach(Array(self.data.enumerated()),id: \.offset) { _data in
                let data = _data.element
                PinterestScrollCard(data: data, width: w, height: totalHeight * 0.3, equalSize: true)
                    .buttonify {
                        self.mainStates.updateSelectedArt(data: data.data)
                    }
            }
        }
        .frame(width: totalWidth, alignment: .center)
    }
    
    var body: some View {
        let w = totalWidth - 20
        if self.equalSize{
            self.CollectionView
        }else{
            LazyHStack(alignment: .top, spacing: 10) {
                self.singleCol(col_dir: "left", width: (w * 0.5 - 5))
                self.singleCol(col_dir: "right", width: (w * 0.5 - 5))
            }.padding()
            .frame(width: totalWidth, alignment: .center)
        }
        
    }
}


struct PinterestScrollCard: View{
    
    var data:AVSData
    var equalSize:Bool
    var width:CGFloat = (totalWidth - 20) * 0.5
    var height:CGFloat? = nil
    init(data:AVSData,width w:CGFloat? = nil,height:CGFloat? = nil,equalSize:Bool = false){
        self.data = data
        if let sw = w{
            self.width = sw
        }
        self.height = height
        self.equalSize = equalSize
    }
    
    var body: some View{
        ImageView(url: self.data.img,heading: self.data.title, width: self.width, height: self.height ?? 0, contentMode: .fill, alignment: .center, autoHeight: !self.equalSize,isPost: true,headingSize: 13)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
}
