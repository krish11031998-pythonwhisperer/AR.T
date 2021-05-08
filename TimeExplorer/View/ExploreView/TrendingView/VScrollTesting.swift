//
//  VScrollTesting.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/03/2021.
//

import SwiftUI

struct VScrollTesting: View {
    
    
    @StateObject var SP:swipeParams = .init()
    
    func onChanged(value:CGSize){
        var width = value.width
        var height = value.height
        
        self.SP.onChanged(value: height)
    }
    
    
    func onEnded(value:CGSize){
        var width = value.width
        var height = value.height
        
        self.SP.onEnded(value: height)
    }
    
    
    func VCardStack() -> some View{
        VStack(alignment: .leading, spacing: 20){
            ForEach([0...5],id:\.self) { id in
                Image(uiImage: .stockImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: totalWidth, height: totalHeight, alignment: .center)
                    .gesture(
                        DragGesture()
                            .onChanged({ (value) in
                                self.onChanged(value: value.translation)
                            })
                            .onEnded({ (value) in
                                self.onEnded(value: value.translation)
                            })
                    )
                    .offset(y: self.SP.extraOffset)
            }
        }
    }
    
    var body: some View {
        self.VCardStack()
            .onAppear(perform: {
                self.SP.end = 5
                self.SP.thresValue = 50
            })
            
    }
}

struct VScrollTesting_Previews: PreviewProvider {
    static var previews: some View {
        VScrollTesting()
    }
}
