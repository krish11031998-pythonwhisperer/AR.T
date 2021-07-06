////
////  PinterestScroll.swift
////  TimeExplorer
////
////  Created by Krishna Venkatramani on 01/06/2021.
////
//
//import SwiftUI
//
//struct PinterestScroll: View {
//
//    var data:[AVSData]
//
//    init(data:[AVSData]){
//        self.data = data
//    }
//
//    func singleCol(col_dir:String = "left",width w:CGFloat) -> some View{
//        let rem = col_dir == "left" ? 0 : 1
//        return VStack(alignment: .center, spacing: 10) {
//            ForEach(Array(self.data.enumerated()),id: \.offset) { _card in
//                let card = _card.element
//                let idx = _card.offset
//
//                if idx%2 == rem{
//                    PinterestScrollCard(data: card, width: w)
//                }
//            }
//        }
//    }
//
//    var body: some View {
//        let w = totalWidth - 20
//        LazyHStack(alignment: .top, spacing: 10) {
//            self.singleCol(col_dir: "left", width: (w * 0.5 - 5))
//            self.singleCol(col_dir: "right", width: (w * 0.5 - 5))
//        }.padding()
//        .frame(width: totalWidth, alignment: .center)
//    }
//}
//
//
//struct PinterestScrollCard: View{
//
//    var data:AVSData
//    var width:CGFloat = (totalWidth - 20) * 0.5
//    init(data:AVSData,width w:CGFloat? = nil){
//        self.data = data
//        if let sw = w{
//            self.width = sw
//        }
//    }
//
//    var body: some View{
//        ImageView(url: self.data.img,heading: self.data.title, width: self.width, contentMode: .fill, alignment: .center, autoHeight: true,isPost: true,headingSize: 13)
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//    }
//
//}
//
////struct PinterestScroll_Previews: PreviewProvider {
////    static var previews: some View {
////        PinterestScroll()
////    }
////}


//
//  PinterestView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 27/06/2021.
//

import SwiftUI

struct PinterestScroll: View {
    
    var data:[AVSData]
    var equalSize:Bool
    init(data:[AVSData],equalSize:Bool = false){
        self.data = data
        self.equalSize = equalSize
    }
    
    func singleCol(col_dir:String = "left",width w:CGFloat) -> some View{
        let rem = col_dir == "left" ? 0 : 1
        return LazyVStack(alignment: .center, spacing: 10) {
            ForEach(Array(self.data.enumerated()),id: \.offset) { _card in
                let card = _card.element
                let idx = _card.offset
                
                if idx%2 == rem{
                    PinterestScrollCard(data: card, width: w,height: totalHeight * 0.3,equalSize: true)
                }
            }
        }
    }
    
    
    func CollectiveImageView(w:CGFloat) -> AnyView{
        if self.equalSize{
            return AnyView(LazyVGrid(columns: [GridItem(.adaptive(minimum: (w * 0.5 - 5), maximum: (w * 0.5 - 5)), spacing: 10, alignment: .center)], alignment: .center, spacing: 10) {
                ForEach(Array(self.data.enumerated()),id: \.offset) { _data in
                    let card = _data.element
                    PinterestScrollCard(data: card, width: (w * 0.5 - 5),height: totalHeight * 0.3,equalSize: true)
                }
            })
        }else{
            return AnyView(LazyHStack(alignment: .top, spacing: 10) {
                self.singleCol(col_dir: "left", width: (w * 0.5 - 5))
                self.singleCol(col_dir: "right", width: (w * 0.5 - 5))
            }.padding()
            .frame(width: totalWidth, alignment: .center))
        }
    }
    
    var body: some View {
        let w = totalWidth - 20
//        LazyHStack(alignment: .top, spacing: 10) {
//            self.singleCol(col_dir: "left", width: (w * 0.5 - 5))
//            self.singleCol(col_dir: "right", width: (w * 0.5 - 5))
//        }.padding()
//        .frame(width: totalWidth, alignment: .center)
        self.CollectiveImageView(w: w)
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
}
