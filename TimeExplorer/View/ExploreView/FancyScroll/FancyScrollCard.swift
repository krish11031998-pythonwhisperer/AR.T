//
//  FancyScrollCard.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 13/05/2021.
//

import SwiftUI

struct FancyCardView:View{
    @EnvironmentObject var scrollStates:FancyScrollStates
    var data:ExploreData
//    var img:String
    var idx:Int
    let cardSize:CGSize = .init(width: totalHeight * 0.3, height: totalHeight * 0.5)
    
    init(data:ExploreData,idx:Int){
        self.data = data
        self.idx = idx
    }
    
    
    var selected:Bool{
        return self.scrollStates.selectedCard == self.idx
    }
    
    
    func checkInView(value:CGFloat,x_axis:Bool = true) -> Bool{
        return value > 0 && value < (x_axis ? totalWidth : totalHeight)
    }
    
    func isMainView(global: CGRect){
        let midX = global.midX
        let midY = global.minY
        let minX = global.minX
        let minY = global.minY
        let maxX = global.maxX
        let maxY = global.maxY
        if self.checkInView(value: midX) && self.checkInView(value: midY,x_axis: false)
            && self.checkInView(value: minX) && self.checkInView(value: maxX)
            && self.checkInView(value: minY,x_axis: false) && self.checkInView(value: maxY,x_axis: false)
        {
            let diff_w = (totalWidth * 0.5) - midX
            let diff_h = (totalHeight * 0.5) - midY
            let res:CGSize = .init(width: diff_w, height: diff_h)

            if self.scrollStates.selectedCard == -1 && self.scrollStates.isViewing != self.idx{
                self.scrollStates.isViewing = self.idx
            }
        }
    }
    
    func onTap(global:CGRect){
        if self.scrollStates.selectedCard != self.idx{
            self.scrollStates.selectedCard = self.idx
            self.scrollStates.centralize_card(res: global.centralize())
            
        }
    }
    
    
    func cardView(local:CGRect,global:CGRect) -> some View{
        let w = local.width
        let h = local.height
//        let view = ZStack(alignment: .center){
//            ImageView(url: self.data.img, width: w, height: h, contentMode: .fill, alignment: .center)
//                .clipShape(Rectangle())
//        }.frame(width: w, height: h, alignment: .center)
//        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .animation(.easeInOut(duration: 1))
//        .onTapGesture(perform: {
//            self.onTap(global:global)
//        })
//        .gesture(DragGesture().onChanged(self.scrollStates.onChanged).onEnded(self.scrollStates.onEnded))
        
        let view = ImageView(url: self.data.img, width: w, height: h, contentMode: .fill, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture(perform: {
                self.onTap(global:global)
            })
            .animation(.easeInOut(duration: 1))
            
            .gesture(DragGesture().onChanged(self.scrollStates.onChanged).onEnded(self.scrollStates.onEnded))
        
        return view
            
    }
    
    
    var body: some View{
        GeometryReader{g -> AnyView in
            let local = g.frame(in: .local)
            let global = g.frame(in: .global)
            DispatchQueue.main.async {
                if self.scrollStates.selectedCard == -1{
                    self.isMainView(global: global)
                }
            }
            
            return AnyView(
                self.cardView(local: local, global: global)
            )
        }.padding(20)
        .frame(width:cardSize.width ,height: cardSize.height, alignment: .center)
        .animation(.easeInOut)
        
        
    }
}

//struct FancyScrollCard_Previews: PreviewProvider {
//
//    static func onChanged(value:DragGesture.Value){
//        print("onChanged")
//    }
//
//    static func onEnded(value:DragGesture.Value){
//        print("onEnded")
//    }
//
//    static var previews: some View {
//        FancyCardView(img: "img1", idx: 1, isViewing: .constant(0), selectedCard: .constant(0), onChanged: self.onChanged(value:), onEnded: self.onEnded(value:)) { rect in
//            print(rect)
//        }
//    }
//}
