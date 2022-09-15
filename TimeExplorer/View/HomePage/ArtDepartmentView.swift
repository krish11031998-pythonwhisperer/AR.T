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
	var data: [AVSData]
	init(data: [AVSData]) {
		self.data = data
		self._viewModel = .init(wrappedValue: .init(department: .allCases.first ?? .japanese))
	}

	
    var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(alignment: .center, spacing: 8) {
					ForEach(Array(Department.allCases.enumerated()), id: \.offset) { department in
						BlobButton(text: department.element.rawValue.systemBody(color: viewModel.selectedColor(department.element)),
								   config: viewModel.blobButtonConfig(department: department.element)) {
							viewModel.selectedDepartment = department.element
						}
						.padding(.leading, department.offset == 0 ? 10 : 0)
						.padding(.trailing, department.offset == Department.allCases.count - 1 ? 10 : 0)
					}
				}
			}
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(alignment: .center, spacing: 8) {
					ForEach(Array(data.enumerated()), id: \.offset) {
						ArtViewCard(data: $0.element, cardSize: .init(width: 150, height: 250))
							.padding(.leading, $0.offset == 0 ? 10 : 0)
							.padding(.trailing, $0.offset == data.count - 1 ? 10 : 0)
					}
				}
			}
		}
    }
}

//struct ArtDepartmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtDepartmentView()
//    }
//}
