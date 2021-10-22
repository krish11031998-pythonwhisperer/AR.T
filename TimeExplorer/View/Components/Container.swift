//
//  Container.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 22/10/2021.
//

import SwiftUI

struct Container<T:View>: View {
    var innerView:(CGFloat) -> T
    var rightButton:T? = nil
    var heading:String
    var onClose:(() -> Void)? = nil
    var width:CGFloat
    var ignoreSides:Bool
    var refreshFn:(() -> Void)? = nil
    init(
        heading:String,
        width:CGFloat = totalWidth,
        ignoreSides:Bool = false,
        onClose:(() -> Void)? = nil,
        @ViewBuilder innerView: @escaping (CGFloat) -> T,
        rightView: (() -> T)? = nil
    ){
        self.heading = heading
        self.innerView = innerView
        self.onClose = onClose
        self.width = width
        self.rightButton = rightView?() ?? nil
        self.ignoreSides = ignoreSides
    }
    
    func headingView(w:CGFloat) -> some View{
        return Group{
            HStack {
                if let onClose = self.onClose{
                    SystemButton(b_name: "xmark",action: onClose)
                }
                MainText(content: self.heading, fontSize: 30, color: .white, fontWeight: .semibold)
                Spacer()
                if rightButton != nil{
                    self.rightButton
                }
            }.padding(.horizontal,self.ignoreSides ? 15 : 0)
            Divider().frame(width:w * 0.5,alignment: .leading)
                .padding(.bottom,10)
        }
        
    }
    
    @ViewBuilder var mainBody:some View{
        let w = totalWidth - 30
        VStack(alignment: .leading, spacing: 10) {
            self.headingView(w: w)
            self.innerView(w)
        }
        .padding(.horizontal, self.ignoreSides ? 0 : 15)
        .frame(width: self.width, alignment: .leading)
        
    }
    
    var body: some View {
        self.mainBody
    }
}

