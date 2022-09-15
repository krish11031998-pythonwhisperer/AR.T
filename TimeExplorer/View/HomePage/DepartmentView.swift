//
//  DepartmentView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 15/09/2022.
//

import SwiftUI
import SUI

class DepartmentViewModel: ObservableObject {
	
	@Published var department: Department {
		didSet {
			loadArtsForDepartment()
		}
	}
	@Published var artData: [CAData] = []
	
	init(department: Department) {
		self._department = .init(initialValue: department)
		loadArtsForDepartment()
	}
	
	private func loadArtsForDepartment() {
		ArtAPIEndpoint
			.search(.init(department: department))
			.execute { [weak self] (result: Result<CAResultBatch,Error>) in
				switch result {
					case .success(let artPieces):
						guard let validData = artPieces.data else { return }
						asyncMainAnimation(animation: .default) {
							self?.artData = validData
						}
					case .failure(let err):
						print("(DEBUG) err : ",err.localizedDescription)
				}
			}
	}
	
	public func blobButtonConfig(_ dpt: Department) -> BlobButtonConfig {
		let selected = department == dpt
		return .init(color: selected ? .purple.opacity(0.15) : .clear, cornerRadius: 16,
					 border: .init(color: department == dpt ? .purple : .white, borderWidth: 1))
	}
	
}

struct DepartmentView: View {
	
	@StateObject var viewModel: DepartmentViewModel
	
	
	init(department: Department) {
		self._viewModel = .init(wrappedValue: .init(department: department))
//		let navigationBarAppearance = UINavigationBarAppearance()
//		navigationBarAppearance.configureWithTransparentBackground()
//		UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
//		UINavigationBar.appearance().standardAppearance = navigationBarAppearance
//		UINavigationBar.appearance().compactAppearance = navigationBarAppearance
	}
	
	private func setupNavBar() {
		let navigationBarAppearance = UINavigationBarAppearance()
		navigationBarAppearance.configureWithTransparentBackground()
		UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
		UINavigationBar.appearance().standardAppearance = navigationBarAppearance
		UINavigationBar.appearance().compactAppearance = navigationBarAppearance
	}
		
	private var departmentOptions: some View {
		SimpleHScroll(data: Department.allCases, config: .original) { dpt in
			BlobButton(text: dpt.rawValue.normal(size: 16, color: .white),
					   config: viewModel.blobButtonConfig(dpt)) {
				withAnimation(.default) {
					viewModel.department = dpt
				}
			}
		}
	}
	
	var gridScrollView: some View {
		LazyVGrid(columns: Array(repeating: .init(.fixed((.totalWidth - 20).half - 5), spacing: 10, alignment: .center), count: 2),
				  alignment: .leading, spacing: 10) {
			ForEach(viewModel.artData, id: \.title) { data in
				ArtViewCard(data: data, cardSize: .init(width: (.totalWidth - 20).half - 5, height: 250))
			}
		}.padding(.horizontal, 10)
	}
	
    var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 8) {
				"Choose a Department".normal(size: 25, color: .white).text
					.padding(.horizontal)
					.fillWidth(alignment: .leading)
				departmentOptions
			}.padding(.vertical, 16)
			
			gridScrollView
				.padding(.bottom, .safeAreaInsets.bottom)
		}
		.background(Color.black)
		.clipped()
		.edgesIgnoringSafeArea(.bottom)
    }
}
