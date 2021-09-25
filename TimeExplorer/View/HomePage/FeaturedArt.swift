//
//  FeaturedArt.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 27/05/2021.
//

import SwiftUI

struct FeaturedArt: View {
//    var art:ArtData = test
    var art:AVSData = .init(img: test.thumbnail, title: test.title, data: test)
    var body: some View {
//        ZStack(alignment: .bottom){
//            Color.black
//            ImageView(url: self.art.img,heading: self.art.title, width: totalWidth, height: totalHeight * 0.45, contentMode: .fill, alignment: .top,isPost: true)
//                .clipped()
//        }
//        .frame(width: totalWidth, height: totalHeight * 0.45, alignment: .center)
//        .shadow(radius: 10)
        ImageView(url: self.art.img, heading: self.art.title, width: totalWidth - 10, height: totalHeight * 0.5, contentMode: .fill, alignment: .center, autoHeight: false, quality: .lowest,clipping: .roundClipping)
//            .clipShape(RoundedRectangle(cornerRadius: 20))
        
    }
}

struct FeaturedArt_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedArt()
    }
}
