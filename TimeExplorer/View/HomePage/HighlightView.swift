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
		.init(width: .totalWidth - 10, height: 350)
	}
	
	private func action(_ idx: Int) {
		print("(DEBUG) selected : ", data[idx])
		let artData = data[idx]
		let infoSnippets: [String: String] = ["Creation Date" : artData.creation_date ?? "",
											  "Technique" : artData.technique ?? "",
											  "Department" : artData.department ?? "" ,
											  "Type" : artData.type ?? ""]
		homePage.selectedArt = .init(id: "\(artData.id ?? 0)",
									 date: .now,
									 title: artData.title ?? "",
									 model_url: nil,
									 introduction: artData.digital_description ?? artData.wall_description ?? "",
									 infoSnippets: infoSnippets,
									 painterName: artData.artistName ?? "",
									 painterImg: artData.title ?? "",
									 top_facts: nil,
									 thumbnail: artData.thumbnail)
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
