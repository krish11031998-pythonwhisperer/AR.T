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
	case departments = "Departments"
	case currentlyOnView = "Current On View"
	case types = "Types"
	case recent = "Recently Acquired"
	case onRadar = "On Your Radar"
	case mayShow = "CMA May Artist"
	case new = "New"
	case artists = "Artists"
}

class HomeViewModel: ObservableObject {
	
	@Published var artworks: [CAData] = []
	@Published var sectionData: [HomeSection : Any] = [:]
	@Published var showArt: Bool = false
	@Published var showDepartments: Bool = false {
		didSet {
			if !showDepartments && selectedDepartment != .none {
				selectedDepartment = .none
			}
		}
	}
	@Published var showTypes: Bool = false
	@Published var selectedDepartment: Department = .none {
		didSet {
			showDepartments = selectedDepartment != .none
		}
	}
	@Published var selectedType: Types = .none
	@Published var selectedArt: ArtData? = nil {
		didSet {
			showArt = selectedArt != nil
		}
	}
	@Published var finishedLoading: Bool = false
	let target_limit:Int = 100
	private let group: DispatchGroup = .init()
	
	private var sectionParams: [HomeSection:SearchParam] = [
		.highlight : .init(skip: 20,limit: 10),
		.currentlyOnView : .init(limit: 5, currently_on_view: true),
		.onRadar : .init(limit: 15, cia_alumni_artists: true),
		.mayShow : .init(may_show_artists: true),
		.recent : .init(recently_acquired: true),
		.new : .init(female_artists: true)
	]
	
	init() {
		print("(DEBUG) Home View Model is init!")
		sectionData[.departments] = Department.allCases
		sectionData[.types] = Types.allCases
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
						self?.sectionData[section] = validArt
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
