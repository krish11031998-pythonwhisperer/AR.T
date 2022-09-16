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
	
	init() {
		getArt()
	}
	
	var paginatedData: [DiscoveryCardData] {
		guard exploreList.count > 25 else { return exploreList.enumerated().map { .init(id: $0.offset, data: $0.element) } }
		return Array(exploreList[0..<25]).enumerated().map { .init(id: $0.offset, data: $0.element)}
	}
	
	func updateShowArt(art: ArtData?){
		if art != nil{
			showArt = true
		}else if showArt{
			showArt = false
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
