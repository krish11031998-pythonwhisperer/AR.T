//
//  ArtDepartmentView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/09/2022.
//

import SwiftUI
import SUI

//MARK: - ArtDepartmentViewModel
class ArtDepartmentViewModel: ObservableObject {
	@Published var selectedDepartment: Department
	
	init(department: Department) {
		self._selectedDepartment = .init(initialValue: department)
	}
	
	func selectedColor(_ department: Department) -> Color {
		return department == selectedDepartment ? .purple : .white
	}
	
	func blobButtonConfig(department: Department) -> BlobButtonConfig {
		.init(color: selectedColor(department).opacity(0.15),
			  cornerRadius: 16, border: .init(color: selectedColor(department), borderWidth: 1))
	}
}


//MARK: - ArtDepartmentView
struct ArtDepartmentView: View {
	@StateObject var viewModel: ArtDepartmentViewModel
	var data: [CAData]
	init(data: [CAData]) {
		self.data = data
		self._viewModel = .init(wrappedValue: .init(department: .allCases.first ?? .japanese))
	}

	private var grid: some View {
		LazyHGrid(rows: [.init(.fixed(240), spacing: 10, alignment: .center),.init(.fixed(240), spacing: 10, alignment: .center)], alignment: .center, spacing: 10) {
			ForEach(data, id: \.title) {
				ArtViewCard(data: $0, cardSize: .init(width: 150, height: 240))
			}
		}
	}
	
    var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			ScrollView(.horizontal, showsIndicators: false) {
				grid
			}
			.fixedHeight(height: 500)
		}
    }
}

