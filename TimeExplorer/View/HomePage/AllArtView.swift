//
//  AllArtView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 01/06/2021.
//

import SwiftUI

struct AllArtView: View {
    var genreCards:[AVSData]
    
    init(genreData:[AVSData] = Array.init(repeating: AVSData(img: asm.img, title: "Classical", data: asm), count: 10)){
        self.genreCards = genreData
    }
    
    
    var artGenres:some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(Array(self.genreCards.enumerated()), id: \.offset){ _art in
                    ArtViewCard(data: _art.element)
                        .shadow(radius: 5)
                        .padding(.leading,_art.offset == 0 ? 10 : 0)
                }
            }.padding(.vertical)
            .frame(height: totalHeight * 0.4, alignment: .center)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            self.artGenres
        }
    }
}

struct ArtViewCard:View{
    var cardData:AVSData
    var cardSize:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.3)
    init(data:AVSData,cardSize:CGSize? = nil){
        self.cardData = data
        if let cs = cardSize{
            self.cardSize = cs
        }
        
    }
    
    var body: some View{
//        ZStack(alignment: .center) {
            ImageView(url: self.cardData.img,heading: self.cardData.title, width: self.cardSize.width, height: self.cardSize.height, contentMode: .fill, alignment: .center, autoHeight: false,headingSize: 25)
//            lightbottomShadow
//            VStack(alignment: .leading, spacing: 10) {
//                Spacer()
//                MainText(content: self.cardData.title ?? "", fontSize: 20, color: .white, fontWeight: .semibold)
//            }.padding()
//            .frame(width: self.cardSize.width, height: self.cardSize.height, alignment: .leading)
//        }.frame(width: self.cardSize.width, height: self.cardSize.height, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
}

struct AllArtView_Previews: PreviewProvider {
    static var previews: some View {
        AllArtView()
    }
}
