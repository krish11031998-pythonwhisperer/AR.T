//
//  SearchViewModel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 18/09/2022.
//

import SwiftUI
import SUI

class SearchViewModel: ObservableObject {
	
	@Published private var searchResult: [CAData] = .init()
	@Published public private(set) var selectedArt: ArtData? = nil
	@Published public var showArt: Bool = false

	var artData: [ArtData] {
		searchResult.compactMap { .init($0) }
	}
	
	public func onCommit(_ q_str: String) {
		ArtAPIEndpoint
			.search(.init(q: q_str))
			.execute { [weak self] (result: Result<CAResultBatch,Error>) in
				switch result {
				case .success(let result):
					guard let validData = result.data else { return }
					asyncMainAnimation {
						self?.searchResult = validData
					}
				case .failure(let err):
					print("(DEBUG) Err : ",err.localizedDescription)
				}
			}
	}
	
	public func onEdit(_ q_str: String) {
		print("(DEBUG) onEdit, textField is currently being editted!")
	}
	
	public func updateArtData(_ artData: ArtData? = nil) {
		withAnimation(.default) {
			selectedArt = artData
			showArt = artData != nil
		}
	}
}
