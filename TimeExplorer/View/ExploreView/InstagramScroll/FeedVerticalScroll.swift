//
//  FeedVerticalScroll.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 15/05/2021.
//

import SwiftUI

struct FeedVerticalScroll: View {
    var dynamic:Bool
    @State var minY:CGFloat = 0
    @State var swiped:Int = 0
    @State var offset:CGFloat = 0
    @State var changeFocus:Bool = false
    var views:[AnyView]
    
    init(view:[AnyView],dynamic:Bool = false){
        self.views = view
        self.dynamic = dynamic
    }
    
    var no_cards:Int{
        return self.views.count
    }
    
    var thresHeight:CGFloat{
        return totalHeight * 0.15
    }
    
    var off_percent:CGFloat{
        let percent = abs(self.offset)/self.thresHeight
        return percent > 1 ? 1 : percent < 0 ? 0 : percent
    }
    
    var swipedOffset:CGFloat{
        let y_off = -CGFloat(self.swiped) * totalHeight
        return y_off
    }
    
    
    func onChanged(value:DragGesture.Value){
//        print("onChanged")
        let height = value.translation.height
        print("onChanged : \(value.translation.height)")
        self.offset = height
    }
    
    func onEnded(value:DragGesture.Value){
        print("onEnded : \(self.offset)")
        let height = value.translation.height
        var off:CGFloat = 0
        var val:Int = 0
        if abs(height) > totalHeight * 0.15{
            val = height > 0 ? -1 : 1
            if self.swiped + val <= self.no_cards - 1 && self.swiped + val >= 0{
                self.swiped += val
//                print("swiped : \(self.swiped)")
            }else if (self.swiped == 0 && height > 0) {
                off = totalHeight
            }else if (self.swiped == self.no_cards - 1 && height < 0) {
                self.swiped = 0
            }
        }
        self.offset = off
        
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(self.views.enumerated()),id: \.offset) { _card in
                let card = _card.element
                let idx = _card.offset
                
                if !self.dynamic{
                    card
                }else{
                    if idx >= self.swiped - 1 && idx <= self.swiped + 1{
                        card
                    }
                }
                
            }
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .top)
        .offset(y: self.swipedOffset + self.offset)
        .animation(.easeInOut)
    }
}

//struct FeedVerticalScroll_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedVerticalScroll()
//    }
//}
