//
//  SwipedParams.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 27/04/2021.
//

import SwiftUI

enum SliderType{
    case Carousel
    case Stack
}


class swipeParams:ObservableObject,Equatable{
    static func == (lhs: swipeParams, rhs: swipeParams) -> Bool {
        return lhs.swiped == rhs.swiped
    }
    
    var start:Int = 0
    var end:Int = 0
    var thresValue:CGFloat = 0
    fileprivate var _type:SliderType = .Carousel
    
    init(_ start:Int? = nil,_ end:Int? = nil, _ thresValue:CGFloat? = nil,type:SliderType = .Carousel){
        self.start = start ?? 0
        self.end = end ?? 0
        self.thresValue = thresValue ?? 100
        self._type = type
    }
    
    var type:SliderType{
        get{
            return self._type
        }
        
        set{
            self._type = newValue
        }
    }
    
    @Published var swiped:Int = 0
    @Published var swipedID:String = ""
    @Published var extraOffset:CGFloat = 0.0
    @Published var xOffset:CGFloat = 0.0
    @Published var yOffset:CGFloat = 0.0
    
    func onChanged(value:CGFloat){
        if self.swiped >= self.start || self.swiped < self.end{
            withAnimation(.easeInOut) {
                self.extraOffset = value;
            }
        }
    }
    
    func updateSwipe(val:Int){
        withAnimation(.easeInOut) {
            self.swiped += val
        }
    }
    
    func onChanged(ges_value:DragGesture.Value){
        let value = self.type == .Carousel ? ges_value.translation.width : ges_value.translation.height
        self.onChanged(value: value)
    }
    
    
    func onEnded(value:CGFloat){
        if abs(value) > self.thresValue{
            var val:Int = 0
            switch(self._type){
                case .Carousel:
                    val = value < 0 && self.swiped < self.end ? 1 : value > 0 && self.swiped > self.start ? -1 : 0
                    break;
                case .Stack:
                    val = value < 0 && self.swiped < self.end ? 1 : value > 0 && self.swiped > self.start ? -1 : 0
            }
            self.updateSwipe(val: val)
        }
        withAnimation(.easeInOut) {
            self.extraOffset = 0
        }
    }
    
    func onEnded(ges_value:DragGesture.Value){
        let value = self.type == .Carousel ? ges_value.translation.width : ges_value.translation.height
        self.onEnded(value: value)
    }
    
    
}
