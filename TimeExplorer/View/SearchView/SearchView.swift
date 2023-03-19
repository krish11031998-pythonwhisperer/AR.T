//
//  SearchView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 16/09/2022.
//

import SwiftUI
import SUI

fileprivate extension CustomTextFieldConfig {
	
	static var original: CustomTextFieldConfig {
		.init(accentColor: .white, foregroundColor: .white, font: .custom(TextStyle.normal.rawValue, size: 15),
			  insets: .init(vertical: 12, horizontal: 15), placeHolder: "Placeholder".systemBody(color: .white), borderColor: .white, borderWidth: 2)
	}
}



struct SearchView: View {
	
	@State var onEdit: String = ""
	@State var onCommit: String	= ""
	@StateObject var viewModel: SearchViewModel
	@EnvironmentObject var mainStates: AppStates
	
	init() {
		self._viewModel = .init(wrappedValue: .init())
	}
	
    var body: some View {
		ZStack(alignment: .center) {
			Color.black
				.edgesIgnoringSafeArea(.all)
			ScrollView(.vertical, showsIndicators: false) {
				CustomTextField(config: .original,searchOnEdit: viewModel.onEdit(_:), searchOnCommit: viewModel.onCommit(_:))
				.padding(.top, 16)
				.padding(.horizontal)
				if !viewModel.artData.isEmpty {
					itemGrid()
						.padding(.vertical, 16)
						.padding(.bottom, .safeAreaInsets.bottom + 100)
				}
			}
			.edgesIgnoringSafeArea(.bottom)
			.clipped()
			artLink
		}
		.toolbar{
			ToolbarItem(placement: .navigationBarLeading) { navigationBarItem }
		}
	}
		
}

//MARK: - SearchView Result

extension SearchView {
	
	@ViewBuilder func itemGrid() -> some View {
		let cardSize: CGSize = .init(width: (.totalWidth - 30).half - 10, height: 220)
		LazyVGrid(columns: [.init(.adaptive(minimum: (.totalWidth - 30).half - 5), spacing: 10, alignment: .center)], spacing: 10) {
			ForEach(viewModel.artData, id: \.id) { data in
				VStack(alignment: .leading,spacing: 10) {
					SUI.ImageView(url: data.thumbnail)
						.framed(size: .init(width: cardSize.width, height: 160), cornerRadius: 10, alignment: .center)
					VStack(alignment: .leading, spacing: 5) {
                        "\(data.painterName ?? "No Name")".styled(font: .mediumItalic, color: .gray, size: 10).text
                        "\(data.title)".body2Bold(color: .white).text
					}
					.padding(.horizontal, 8)
					.frame(width: cardSize.width, height: 50, alignment: .leading)
				}
				.buttonify {
					viewModel.updateArtData(data)
					mainStates.showTab = false
				}
			}
		}.padding(.horizontal, 15)
	}
	
}


//MARK: - SearchView NavigationView

extension SearchView {
	
	@ViewBuilder var artLink: some View {
		NavLink(isActive: $viewModel.showArt) {
			ArtScrollMainView(data: viewModel.selectedArt ?? .init(date: .now, title: "", introduction: ""), showArt: $viewModel.showArt)
		}
	}
	
	var navigationBarItem: some View {
		"Search".heading2().text
	}
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			SearchView()
		}
    }
}
