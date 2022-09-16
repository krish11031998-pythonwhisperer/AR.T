//
//  SideScroll.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 28/05/2021.
//

import SwiftUI
import SUI

struct TrendingArt: View {
	@EnvironmentObject var homePage: HomeViewModel
	var cardSize:CGSize = .init(width: .totalWidth.half.boundedTo(lower: 200, higher: 350), height: 350)
    var data:[CAData] = []
    
    init(data:[CAData]){
        self.data = data
    }
    
	func action(_ artData: CAData) {
		let infoSnippets = ["Creation Date" : artData.creation_date,
							"Technique" : artData.technique,
							"Department" : artData.department,
							"Type" : artData.type
							].filter{ $0.value != nil }
		homePage.selectedArt = .init(id: "\(artData.id ?? 0)",
									 date: .now,
									 title: artData.title ?? "",
									 model_url: nil,
									 introduction: artData.digital_description ?? artData.wall_description ?? "",
//									 infoSnippets: ["Creation Date" : artData.creation_date,
//													"Technique" : artData.technique,
//													"Department" : artData.department,
//													"Type" : artData.type
//												   ].filter{ $0.value != nil },
									 painterName: artData.artistName ?? "",
									 painterImg: artData.title ?? "",
									 top_facts: nil,
									 thumbnail: artData.thumbnail)
	}
    
    var body: some View {
		CascadingCardStack(data: data, offFactor: .totalWidth * 0.25,pivotFactor: 5, action: action(_:)) { data, isSelected in
			ZStack(alignment: .bottomLeading) {
				SUI.ImageView(url: data.thumbnail)
					.framed(size: cardSize)
				if !isSelected {
					BlurView(style: .light)
				} else {
					(data.title ?? "No title").normal(size: 13, color: .white)
						.text
						.padding(10)
						.fillWidth(alignment: .leading)
				}
			}.framed(size: cardSize, cornerRadius: 14, alignment: .center)
		}
    }
}
