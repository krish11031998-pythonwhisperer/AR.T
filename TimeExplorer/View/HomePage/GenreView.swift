//
//  AllArtView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 01/06/2021.
//

import SwiftUI
import SUI

struct GenreView: View {
    var genreCards:[AVSData]
    
    init(genreData:[AVSData] = Array.init(repeating: AVSData(img: asm.img, title: "Classical", data: asm), count: 10)){
        self.genreCards = genreData
    }
    
    
    var artGenres:some View{
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 10) {
                ForEach(Array(self.genreCards.enumerated()), id: \.offset){ _art in
                    ArtViewCard(data: _art.element)
                        .shadow(radius: 5)
                        .padding(.leading,_art.offset == 0 ? 10 : 0)
                }
            }
        }.padding(.vertical)
    }
    
    var body: some View {
        self.artGenres
    }
}

struct ArtViewCard:View{
    let cardData:AVSData
	let cardSize: CGSize
    init(data:AVSData, cardSize:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.3)){
        self.cardData = data
		self.cardSize = cardSize
    }
    
    var body: some View{
		ZStack(alignment: .bottomLeading) {
			SUI.ImageView(url: cardData.img)
				.framed(size: cardSize, cornerRadius: 0, alignment: .center)
			lightbottomShadow.fillFrame()
			VStack(alignment: .leading, spacing: 10) {
				(cardData.title ?? "No Title").normal(size: 12).text
				RoundedRectangle(cornerRadius: 20)
					.fill(Color.white.opacity(0.35))
					.fixedHeight(height: 2)
					.padding(.bottom,10)
			}
			.padding()
			.fillFrame(alignment: .bottomLeading)
		}
		.framed(size: cardSize, cornerRadius: 12, alignment: .center)
    }
    
}

struct AllArtView_Previews: PreviewProvider {
    static var previews: some View {
        GenreView()
    }
}
