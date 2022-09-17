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
    
    
    
    var header:some View{
        HStack(alignment: .center, spacing: 10){
            MainText(content: "Discover", fontSize: 30, color: .white, fontWeight: .bold, style: .heading)
            Spacer()
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
        }.padding()
        .padding(.top,35)
        .frame(width: totalWidth, alignment: .leading)
        .background(bottomShadow.rotationEffect(.init(degrees: .init(180))))
    }
	
	@ViewBuilder var selectedArtView: some View {
		if let art = viewModel.art{
			ArtScrollMainView(data: art, showArt: $viewModel.showArt)
		} else {
			Color.clear.frame(size: .zero)
		}
	}

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
			if !mainStates.loading{
				DiscoveryView(data: viewModel.paginatedData,
							  model: .init(cardSize: .init(width: 200, height: 350), rows: 5, spacing: 10, bgColor: .clear)) { data in
					SUI.ImageView(url: (data.data as? ExploreData)?.img)
						.framed(size: .init(width: 200, height: 350), cornerRadius: 15, alignment: .center)
						.onTapGesture {
							withAnimation(.easeInOut(duration: 0.5)) {
								viewModel.art = (data.data as? ExploreData)?.data as? ArtData
								viewModel.idx = data.id
							}
						}
						.cardSelected(viewModel.idx)
				}
			}
			header
        }
		.edgesIgnoringSafeArea(.all)
		.onReceive(viewModel.$exploreList, perform: { newValue in
			withAnimation(.default) {
				mainStates.loading = newValue.isEmpty
			}
		})
        .onChange(of: viewModel.art, perform: viewModel.updateShowArt(art:))
        .onDisappear(perform: self.mainStates.toggleTab)
		.fullScreenModal(isActive: $viewModel.showArt, config: .init(isDraggable: false, showCloseIndicator: true)) {
			selectedArtView
		}
		.navigationBarHidden(true)

    }
}

struct FancyScrollMain_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
