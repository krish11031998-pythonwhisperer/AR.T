//
//  HorizontalDragView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 22/10/2021.
//

import SwiftUI

struct HorizontalDragView<T:View>: View {
    @StateObject var SP:swipeParams
    var innerView:[T]
    var el_size:CGSize

    init(count:Int,el_size:CGSize,@ViewBuilder innerView: () -> [T]){
        self._SP = .init(wrappedValue: .init(0, count, type: .Carousel))
        self.el_size = el_size
        self.innerView = innerView()
    }
    
    
    func onChanged(val:DragGesture.Value){
        self.SP.onChanged(ges_value: val)
    }
    
    func onEnded(val:DragGesture.Value){
        self.SP.onEnded(ges_value: val)
    }
    
    var offset:CGFloat{
        return -CGFloat(self.SP.swiped) * self.el_size.width
    }
    
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ForEach(Array(self.innerView.enumerated()),id:\.offset) { _innerView in
                let view = _innerView.element
                let idx = _innerView.offset
                
                view
                    .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))
                    .id(idx)
            }
        }.offset(x: self.SP.extraOffset + self.offset)
    }
}
