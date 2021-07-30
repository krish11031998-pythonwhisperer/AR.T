//
//  ArtistArtView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 30/07/2021.
//

import SwiftUI

struct ArtistArtView: View {
    
    var data:[AVSData]
    
    init(data:[AVSData] = .init(repeating: asm, count: 4)){
        self.data = data
    }
    
    func TopImageView(size:CGSize) -> some View{
        let w = size.width
        let h = size.height
        return
            GeometryReader{g in
                HStack(alignment: .center, spacing: 5) {
                    ImageView(url: self.data.first?.img, width: w * 0.5 - 2.5, height: h - 5, contentMode: .fill, alignment: .center, headingSize: 10, quality: .lowest)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    VStack(alignment: .center, spacing: 5) {
                        ForEach(Array(self.data[1...].enumerated()),id: \.offset) { _data in
                            let data = _data.element
                            
                            ImageView(url: data.img, width: w * 0.5 - 2.5, height: h * 0.5 - 5, contentMode: .fill, alignment: .center, quality: .lowest)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                }
            }
            .frame(width: w, height: h, alignment: .center)
        
        
    }

    var TopImageView:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            VStack(alignment: .leading, spacing: 10) {
                self.TopImageView(size: .init(width: w, height: h * 0.8))
                MainText(content: "Krishna Venkatramani", fontSize: 30, color: .white, fontWeight: .regular)
                MainText(content: "Classical Art", fontSize: 15, color: .white, fontWeight: .bold)
            }
            .frame(width: w, height: h, alignment: .leading)
            
        }.padding(.horizontal,10)
        .padding(.vertical,20)
        .frame(width: totalWidth, height: totalHeight * 0.4, alignment: .center)
        .background(BlurView(style: .dark))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
    }
    
    var body: some View {
        self.TopImageView
    }
}

struct ArtistArtView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistArtView()
    }
}
