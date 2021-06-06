//
//  FeaturedArt.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 27/05/2021.
//

import SwiftUI

struct FeaturedArt: View {
    var art:ArtData = test
    var body: some View {
        GeometryReader{g in
            let local = g.frame(in: .local)
            let w = local.width
            let h = local.height
            
            ZStack(alignment: .bottom){
                Color.black
                ImageView(url: self.art.thumbnail,heading: self.art.title, width: w, height: h, contentMode: .fill, alignment: .top,isPost: true)
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }.padding()
        .frame(width: totalWidth, height: totalHeight * 0.35, alignment: .center)
        .shadow(radius: 10)
        
    }
}

struct FeaturedArt_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedArt()
    }
}
