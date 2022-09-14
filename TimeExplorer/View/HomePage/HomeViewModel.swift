//
//  HomeViewModel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/09/2022.
//

import Foundation
import Combine
import SUI

enum HomeSection: String, CaseIterable {
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
	@Published var sectionData: [HomeSection: [AVSData]] = [:]
	@Published var showArt: Bool = false
	@Published var selectedArt: ArtData? = nil {
		didSet {
			showArt = selectedArt != nil
		}
	}
	@Published var finishedLoading: Bool = false
	let target_limit:Int = 100
	private let group: DispatchGroup = .init()
	
	private var sectionParams: [HomeSection:SearchParam] = [
		.highlight : .init(),
		.trending : .init(department: .japanese),
		.onRadar : .init(department: .modern_european),
		.recommended : .init(type: .calligraphy),
		.recent : .init(type: .armsAndArmor),
		.new : .init(type: .illumination)
	]
	
	init() {
		print("(DEBUG) Home View Model is init!")
		loadData()
	}
	
	
	
	func loadData() {
		sectionParams.forEach {
			loadDataForSection(section: $0.key, param: $0.value)
		}
		group.notify(queue: .main) {
			self.finishedLoading = true
		}
	}
	
	func loadDataForSection(section: HomeSection, param: SearchParam) {
		group.enter()
		ArtAPIEndpoint
			.search(param)
			.execute { [weak self] (result:Result<CAResultBatch,Error>) in
				switch result {
				case .success(let art):
					guard let validArt = art.data else { return }
					asyncMainAnimation {
						self?.sectionData[section] = validArt.compactMap { .init($0) }
						self?.group.leave()
					}
				case .failure(let err):
					print("(DEBUG) err : ",err.localizedDescription)
					self?.group.leave()
				}
			}
	}
	
	var sections: [HomeSection] = HomeSection.allCases
	
	
	
}
