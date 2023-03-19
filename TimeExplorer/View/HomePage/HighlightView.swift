//
//  HighlightView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 22/07/2021.
//

import SwiftUI
import SUI

struct HighlightView: View {
	@EnvironmentObject var homePage: HomeViewModel
    var data:[CAData]
	
	init(data:[CAData]){
        self.data = data
    }
	
	private var cardSize: CGSize {
		.init(width: .totalWidth - 32, height: 350)
	}
	
	private func action(_ idx: Int) {
		let artData = data[idx]
		homePage.setArt(artData)
	}
	
    var body: some View {
		SlideOverCarousel(data: data, config: .withTimer){ viewData in
			AuctionCard(data: viewData,
						cardConfig: .init(bids: nil,
										  showBar: false,
										  cardStyling: .rounded(14),
										  cardSize: cardSize ))
		} action: {action($0)}
    }
}

//struct HighlightView_Previews: PreviewProvider {
//    static var previews: some View {
//        HighlightView(data: Array(repeating: tes, count: 5))
//    }
//}
