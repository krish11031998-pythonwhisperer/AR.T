//
//  FeaturedArt.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 27/05/2021.
//

import SwiftUI

struct FeaturedArt: View {
    var art:AVSData = .init(img: test.thumbnail, title: test.title, data: test)
    var body: some View {
        ImageView(url: self.art.img, heading: self.art.title, width: totalWidth - 10, height: totalHeight * 0.5, contentMode: .fill, alignment: .center, autoHeight: false, quality: .lowest,clipping: .roundClipping)
    }
}

struct FeaturedArt_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedArt()
    }
}
