//
//  TrendingViewModel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 16/09/2022.
//

import Foundation
import Combine
import SUI

class TrendingViewModel: ObservableObject {
	
	@Published var data: [TrendingCardData] = []
	@Published var offset: Int = 0
	@Published var showArt: Bool = false
	@Published var currentCard: TrendingCardData? = nil
	@Published var artAPI: FirebaseArtAPI = .init()
	init() {
		getArt()
	}
	
	var paginatedData: [TrendingCardData] {
		offset < data.count && offset + 25 < data.count ? Array(data[offset + 0...offset+25]) : data
	}
	
	func getArt() {
		artAPI.getArts(limit: 20) { [weak self] result in
			switch result {
			case .success(let art):
				asyncMainAnimation(animation: .default) {
					self?.data = art.compactMap { .init(image: $0.thumbnail,
														username: $0.title,
														mainText: $0.title,
														type: .art, data: $0, date: .now) }
				}
			case .failure(let err):
				print("(DEBUG) err: ",err.localizedDescription)
			}
		}
			
	}
	
}
