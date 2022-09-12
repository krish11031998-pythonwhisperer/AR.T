//
//  HighlightView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 22/07/2021.
//

import SwiftUI
import SUI

struct HighlightView: View {
    var data:[AVSData]
	
    init(data:[AVSData]){
        self.data = data
    }
	
    var body: some View {
		SlideOverCarousel(data: data, config: .withTimer){ viewData in
			if let artData = viewData as? AVSData {
				AuctionCard(data: artData,
							cardConfig: .init(bids: .init(bids: .random(in: 0...100), price: .random(in: 0...100), currency: "BTC"),
											  showBar: true,
											  cardStyling: .rounded(14),
											  cardSize:  .init(width: .totalWidth - 10, height: 350)))
			} else {
				Color.brown
			}
		} action: { idx in
			print("(DEBUG) selected : ", data[idx])
		}
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView(data: Array(repeating: asm, count: 5))
    }
}
