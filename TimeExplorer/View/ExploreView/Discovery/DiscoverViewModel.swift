//
//  DiscoverViewModel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 16/09/2022.
//

import Foundation
import SUI

class DiscoverViewModel: ObservableObject {
	
	@Published var exploreList : [ExploreData] = []
	@Published var art:ArtData? = nil
	@Published var showArt:Bool = false
	@Published var idx:Int = -1
	@Published var offset: Int = 0
	
	init() {
		getArt()
	}
	
	var paginatedData: [DiscoveryCardData] {
		guard (offset + 1) * 25 < exploreList.count else { return exploreList.enumerated().map { .init(id: $0.offset, data: $0.element) } }
		let count = (offset + 1) * 25
		let arr = Array(exploreList[(offset * 25)..<(offset + 1) * 25])
		return arr.enumerated().map { .init(id: $0.offset, data: $0.element)}
	}
	
	func updateShowArt(art: ArtData?){
		if art != nil{
			showArt = true
		}else if showArt {
			showArt = false
		}
	}
	
	func updateOffset(_ newValue: Int) {
		if (offset + newValue) * 25 < exploreList.count {
			offset += newValue
		}
	}
	
	func getArt() {
		ArtAPIEndpoint
			.search(.init(skip:100, limit: 100))
			.execute { [weak self] (result: Result<CAResultBatch,Error>) in
				switch result {
				case .success(let batch):
					guard let validArt = batch.data else { return }
					asyncMainAnimation(animation: .default) {
						self?.exploreList = validArt.compactMap { .init(img: $0.images?.web?.url, data: $0) }
					}
				case .failure(let err):
					print("(DEBUG) err : ",err.localizedDescription)
				}
			}
	}
}
