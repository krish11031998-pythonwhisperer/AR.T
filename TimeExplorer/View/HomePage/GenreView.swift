//
//  AllArtView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 01/06/2021.
//

import SwiftUI
import SUI

struct GenreView: View {
    var genreCards:[CAData]
    
    init(genreData:[CAData]){
        self.genreCards = genreData
    }
    
    
    var artGenres:some View{
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 10) {
                ForEach(Array(genreCards.enumerated()), id: \.offset){ _art in
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
    let cardData:CAData
	let cardSize: CGSize
    init(data:CAData, cardSize:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.3)){
		print("(DEBUG) artViewCard init called!")
        self.cardData = data
		self.cardSize = cardSize
    }
    
    var body: some View{
		ZStack(alignment: .bottomLeading) {
			SUI.ImageView(url: cardData.thumbnail)
				.framed(size: cardSize, cornerRadius: 0, alignment: .top)
			lightbottomShadow.fillFrame()
			VStack(alignment: .leading, spacing: 10) {
				(cardData.title ?? "No Title").body1Bold().text
					.lineLimit(2)
                CustomDivider()
                (cardData.artistName ?? "Artist").styled(font: .mediumItalic, color: .white, size: 12).text
			}
			.padding()
			.fillFrame(alignment: .bottomLeading)
		}
		.framed(size: cardSize, cornerRadius: 12, alignment: .center)
    }
    
}

//struct AllArtView_Previews: PreviewProvider {
//    static var previews: some View {
//        GenreView()
//    }
//}
