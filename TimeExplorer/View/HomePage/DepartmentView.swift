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
	
}

struct DepartmentView: View {
	
	@StateObject var viewModel: DepartmentViewModel
	
	
	init(department: Department) {
		self._viewModel = .init(wrappedValue: .init(department: department))
		setupNavBar()
	}
	
	private func setupNavBar() {
		let navigationBarAppearance = UINavigationBarAppearance()
		navigationBarAppearance.configureWithTransparentBackground()
		UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
		UINavigationBar.appearance().standardAppearance = navigationBarAppearance
		UINavigationBar.appearance().compactAppearance = navigationBarAppearance
	}
		
	private var departmentOptions: some View {
//		SimpleHScroll(data: Department.allCases, config: .original) { dpt in
//
//			BlobButton(text: dpt.rawValue.systemBody(color: .white),
//					   config: .init(color: .purple.opacity(0.15), cornerRadius: 16,
//									 border: .init(color: .purple, borderWidth: 1))) {
//				withAnimation(.default) {
//					viewModel.department = dpt
//				}
//			}
//		}
		Color.clear.frame(size: .zero)
	}
	
	var gridScrollView: some View {
		LazyVGrid(columns: Array(repeating: .init(.fixed((.totalWidth - 20).half - 5), spacing: 10, alignment: .center), count: 2),
				  alignment: .leading, spacing: 10) {
			ForEach(viewModel.artData, id: \.title) { data in
				VStack(alignment: .leading, spacing: 8) {
					SUI.ImageView(url: data.thumbnail)
						.framed(size: .init(width: (.totalWidth - 20).half - 5, height: 150),cornerRadius: 4, alignment: .top)
					(data.title ?? "No Title").normal(size: 14).text
				}
			}
		}.padding(.horizontal, 10)
	}
	
    var body: some View {
		ScrollView {
			departmentOptions
			gridScrollView
				.padding(.bottom, .safeAreaInsets.bottom)
		}
		.background(Color.black)
		.clipped()
		.edgesIgnoringSafeArea(.bottom)
    }
}

//struct DepartmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        DepartmentView()
//    }
//}
