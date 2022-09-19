//
//  FancyScrollMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/05/2021.
//

import SwiftUI
import SUI

struct DiscoverView: View {
    @EnvironmentObject var mainStates:AppStates
	@StateObject var viewModel: DiscoverViewModel = .init()
	@Namespace var animation
	
	let cardSize: CGSize = .init(width: 200, height: 350)
	
    var body: some View {
        ZStack(alignment: .top) {
            Color.black
			if !viewModel.paginatedData.isEmpty && !mainStates.loading{
				DiscoveryView(data: viewModel.paginatedData,
							  model: .init(cardSize: cardSize, rows: 5, spacing: 10, bgColor: .clear)) { data in
					SUI.ImageView(url: (data.data as? ExploreData)?.img)
						.framed(size: cardSize, cornerRadius: 15, alignment: .center)
						//.matchedGeometryEffect(id: "artCard.\(data.id)", in: animation, isSource: true)
						.onTapGesture {
							handleTap(data: data)
						}
						.cardSelected(viewModel.idx)
				}
			}
			selectedArtState
        }
		.edgesIgnoringSafeArea(.all)
		.onAppear(perform: onAppear)
		.onReceive(viewModel.$exploreList, perform: onReceiveExploreList(_:))
        .onDisappear(perform: onDisappear)
		.fullScreenModal(isActive: $viewModel.showArt, config: .init(isDraggable: false, showCloseIndicator: true)) {
			selectedArtView
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				leadingNavBarItem
			}
			
			ToolbarItem(placement: .navigationBarTrailing) {
				trailingNavBarItem
			}
		}

    }
}

//MARK: - Discover View Child Views

extension DiscoverView {
	
	@ViewBuilder var selectedArtView: some View {
		if let art = viewModel.art{
			ArtScrollMainView(data: art, showArt: $viewModel.showArt)
		} else {
			Color.clear.frame(size: .zero)
		}
	}
	
	@ViewBuilder var selectedArtState: some View {
		if let validArt = viewModel.art, viewModel.idx != -1 {
			ZStack {
				BlurView(style: .regular)
					.fillFrame(alignment: .center)
					.onTapGesture {
						withAnimation {
							viewModel.idx = -1
							viewModel.art = nil
						}
					}
				SUI.ImageView(url: validArt.thumbnail)
					.framed(size: cardSize, cornerRadius: 15, alignment: .center)
					//.matchedGeometryEffect(id: "artCard.\(viewModel.idx)", in: animation, properties: .position, isSource: false)
				VStack(alignment: .leading, spacing: 8) {
					validArt.title.normal(size: 20).text.lineLimit(2)
					validArt.introduction.normal(size: 15).text.lineLimit(3)
					CustomButton(config: .init(imageName: .next,text: "View art".normal(size: 12))) {
						viewModel.updateShowArt(art: validArt)
					}
				}
				.transitionFrom(.bottom)
				.padding()
				.padding(.bottom, .safeAreaInsets.bottom)
				.fillFrame(alignment: .bottomLeading)
			}
			.edgesIgnoringSafeArea(.all)
			.fillFrame(alignment: .center)
			
		}
	}
}


//MARK: - Discover View NavBar Extension

extension DiscoverView {
	
	var leadingNavBarItem: some View {
		"Discover".normal(size: 30).text
	}
	
	var trailingNavBarItem: some View {
		HStack(alignment: .center, spacing: 8) {
			SystemButton(b_name: "homekit", b_content: "",color: .white, size: .init(width: 20, height: 20)) {
				self.mainStates.tab = "home"
			}
			SystemButton(b_name: "arrow.clockwise",
						 b_content: "",
						 color: .white,
						 haveBG: true,
						 size: .init(squared: 20),
						 bgcolor: .black) {
				viewModel.updateOffset(1)
			}
		}
	}
}

//MARK: - Discover View Handlers Extension

extension DiscoverView {
	
	private func onDisappear() {
		if !mainStates.showTab {
			withAnimation {
				mainStates.showTab = true
			}
		}
	}
	
	private func onReceiveExploreList(_ exploreList: [ExploreData]) {
		withAnimation {
			mainStates.loading = exploreList.isEmpty
		}
	}
	
	private func onAppear() {
		if mainStates.showTab {
			withAnimation {
				mainStates.showTab = false
			}
		}
		
		if !viewModel.exploreList.isEmpty {
			mainStates.loading = false
		}
	}
	
	private func handleTap(data: DiscoveryCardData) {
		guard let validData = (data.data as? ExploreData)?.data as? CAData else { return }
		withAnimation(.easeInOut(duration: 0.5)) {
			viewModel.art = .init(validData)
			viewModel.idx = data.id
		}
	}
}

struct FancyScrollMain_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
