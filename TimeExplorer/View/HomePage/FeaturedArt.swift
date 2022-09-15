//
//  FeaturedArt.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 27/05/2021.
//

import SwiftUI

struct FeaturedArt: View {
    var art:CAData
    var body: some View {
        ImageView(url: self.art.thumbnail, heading: self.art.title, width: totalWidth - 10, height: totalHeight * 0.5, contentMode: .fill, alignment: .center, autoHeight: false, quality: .lowest)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
//
//struct FeaturedArt_Previews: PreviewProvider {
//    static var previews: some View {
//        FeaturedArt()
//    }
//}
