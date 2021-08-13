//
//  FancyScroll_Structs.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/05/2021.
//

import SwiftUI

class FancyScrollStates:ObservableObject{
    
    @Published var dynamic_off:CGSize = .zero
    @Published var static_off:CGSize = .zero
    @Published var isViewing:Int = -1
    @Published var selectedCard:Int = -1
    @Published var changeIdx:Bool = false
    @Published var dragging:Bool = false
    @Published var showArt:Bool = false
    
    var cardSize:CGSize = .zero
    
    
    init(size:CGSize){
        self.cardSize = size
    }
    
    
    func centralize_card(res:CGSize){
        self.static_off.width += res.width
        self.static_off.height += res.height - cardSize.height * 0.25
    }
    
    func centralizeContainer(rect:CGRect){
        var diff_x : CGFloat = 0.0
        var diff_y : CGFloat = 0.0
        if rect.minY > 25{
            diff_y -= rect.minY - 50
        }
        if rect.minX > 25{
            let diff = rect.minX
            diff_x -= diff
        }
        
        if rect.maxX <= totalWidth{
            let diff = totalWidth - rect.maxX
            diff_x += diff
        }
        
        if rect.maxY <= totalHeight{
            let diff = totalHeight - rect.maxY
            diff_y += diff
        }
        
        self.static_off.height += diff_y
        self.static_off.width += diff_x
    }
    
    func onChanged(value:DragGesture.Value){
        if self.selectedCard != -1{
            //            self.selectedCard = -1
            return
        }
        
        if !self.dragging{
            self.dragging = true
        }
        let factor:CGFloat = 1.25
        let h = value.translation.height * factor
        let w = value.translation.width * factor
        let delta:CGSize = .init(width: w, height: h)
        self.dynamic_off = delta
    }
    
    func onEnded(value:DragGesture.Value){
        let w_off:CGFloat = self.dynamic_off.width
        let h_off:CGFloat = self.dynamic_off.height
        self.static_off.width += w_off
        self.static_off.height += h_off
        self.dynamic_off = .zero
    }
}
