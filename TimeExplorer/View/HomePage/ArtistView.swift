//
//  ArtistView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 25/06/2021.
//

import SwiftUI

struct ArtistView: View {
    var data:[AVSData]
    init(data: [AVSData]){
        self.data = data
    }
    
    var w:CGFloat{
        return totalWidth * 0.33
    }
    
    private var HScroll:some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                ForEach(Array(self.data.enumerated()),id: \.offset) { _data in
                    let data = _data.element
                    let idx = _data.offset
                    
                    ImageView(url: data.img, width: w, height: w, contentMode: .fill, alignment: .center)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    var body: some View {
        self.HScroll
    }
}

struct ArtistView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistView(data: Array(repeating: asm, count: 10))
    }
}
