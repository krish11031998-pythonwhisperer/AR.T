//
//  BlogViewCard.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 16/01/2021.
//

import SwiftUI

struct BlogViewCard: View {
    var data:TrendingCardData
    var w:CGFloat
    var h:CGFloat
    @StateObject var IMD:ImageDownloader = .init()
    
    var onTopCard:some View{
        var image = self.IMD.image
        var ar = UIImage.aspectRatio(img: image)
        return Image(uiImage: self.IMD.image)
            .resizable()
            .aspectRatio(ar, contentMode: .fill)
            .frame(width: w, height: h, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
    }
    
    var body: some View {
        ZStack(alignment:.center){
            
        }
    }

}

//struct BlogViewCard_Previews: PreviewProvider {
//    static var previews: some View {
//        BlogViewCard()
//    }
//}
