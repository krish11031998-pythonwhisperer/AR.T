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
	@Binding var art: ArtData?
	
	init(data:[AVSData], art: Binding<ArtData?> = .constant(nil)){
        self.data = data
		self._art = art
    }
	
	private var cardSize: CGSize {
		.init(width: .totalWidth - 10, height: 350)
	}
	
	private func action(_ idx: Int) {
		print("(DEBUG) selected : ", data[idx])
		guard let artData = data[idx].data as? CAData else { return }
		self.art = .init(id: "\(artData.id ?? 0)", date: .now, title: artData.title ?? "", model_url: nil, introduction: artData.digital_description ?? artData.wall_description ?? ""
						 , painterName: artData.artistName ?? "", painterImg: artData.title ?? "", top_facts: nil, thumbnail: artData.thumbnail)
	}
	
    var body: some View {
		SlideOverCarousel(data: data, config: .withTimer){ viewData in
			if let artData = viewData as? AVSData {
				AuctionCard(data: artData,
							cardConfig: .init(bids: nil,
											  showBar: false,
											  cardStyling: .rounded(14),
											  cardSize: cardSize ))
			} else {
				Color.brown
			}
		} action: {action($0)}
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView(data: Array(repeating: asm, count: 5))
    }
}
