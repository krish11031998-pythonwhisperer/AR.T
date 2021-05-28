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
                ImageView(url: self.art.thumbnail, width: w, height: h, contentMode: .fill, alignment: .top, testMode: true)
                    
                lightbottomShadow
                    .frame(width: w, height: h, alignment: .center)
                MainText(content: self.art.title, fontSize: 35, color: .white, fontWeight: .semibold, style: .normal)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.bottom,30)
                    .frame(width: w, alignment: .leading)
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
//            .clipShape(ArcCorners(corner: .bottomRight, curveFactor: 0.025, cornerRadius: 20, roundedCorner: .allCorners))
            
        }.padding()
        .frame(width: totalWidth, height: totalHeight * 0.5, alignment: .center)
        
    }
}

struct FeaturedArt_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedArt()
    }
}
