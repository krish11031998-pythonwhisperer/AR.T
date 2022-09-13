//
//  HomeViewModel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/09/2022.
//

import Foundation
import Combine
import SUI

enum HomeSection: String {
	case highlight = "Hightlight of the Day"
	case trending = "Trending"
	case onRadar = "On Your Radar"
	case recommended = "Recommendation"
	case recent = "Recent"
	case new = "New"
	case artists = "Artists"
}

extension AVSData {
	
	init(_ data: CAData) {
		self.init(img: data.images?.web?.url, title: data.title, data: data)
	}
}

class HomeViewModel: ObservableObject {
	
	@Published var artworks: [AVSData] = []
	@Published var showArt: Bool = false
	@Published var selectedArt: ArtData? = nil {
		didSet {
			showArt = selectedArt != nil
		}
	}
	let target_limit:Int = 100
	
	func loadData() {
		ArtAPIEndpoint
			.search(.init())
			.execute { [weak self] (result:Result<CAResultBatch,Error>) in
				switch result {
					case .success(let art):
						guard let validArt = art.data else { return }
						asyncMainAnimation(animation: .default) {
							self?.artworks = validArt.compactMap{ .init($0) }
						}
					case .failure(let error):
						print("(DEBUG) err : ",error.localizedDescription)
				}
		}
	}
	
	var sections: [HomeSection] = [.highlight, .trending, .onRadar, .recommended, .recent, .new]
	
}
