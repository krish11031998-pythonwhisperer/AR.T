//
//  TourViewMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 03/01/2021.
//
import SwiftUI
import FirebaseFirestoreSwift
import SUI


enum CardType:String{
    case art = "Art"
}
struct TrendingCardData:Identifiable{
    var id:Int?
    var image:String?
    var vid_url:String?
    var username:String?
    var userImg:String?
    var mainText:String?
    var type:CardType
    var data:Any?
    var location:String?
    var date:Date
    var mainImage:UIImage?
}

struct TrendingData{
    var type:CardType
    var data:Any

    func parseVisualData() -> TrendingCardData?{
        var res:TrendingCardData? = nil
        let _data = self
        switch(self.type){
            case .art:
                guard let data = _data.data as? ArtData else {return res}
			res = .init(image: data.thumbnail, vid_url:data.main_vid_url, mainText: data.title, type: .art, data: data,date: .now)
        }
        return res
    }
}

struct TrendingMainView: View {
	@StateObject var viewModel: TrendingViewModel
    @EnvironmentObject var mainStates:AppStates

	init() {
		_viewModel = .init(wrappedValue: .init())
	}
	
    func updateViewState(){
        viewModel.showArt.toggle()
    }
	
	func trendingCardBuilder(data: TrendingCardData, isSelected: Bool) -> some View {
		if isSelected {
			DispatchQueue.main.async {
				self.viewModel.currentCard = data
			}
		}
		return TrendingMainCard(data, handler: updateViewState)

	}

	@ViewBuilder func artInnerView() -> some View {
		if let data = viewModel.currentCard?.data as? ArtData, viewModel.showArt {
			ArtScrollMainView(data: data,showArt: $viewModel.showArt)
				.environmentObject(self.mainStates)
		} else {
			Color.black
				.framed(size: .init(width: .totalWidth, height: .totalHeight), cornerRadius: 0, alignment: .center)
		}
	}

    var body: some View {
        ZStack(alignment:.top){
            Color.black
			if !viewModel.data.isEmpty && !self.mainStates.loading{
				StackedScroll(data: viewModel.paginatedData) { pageData, isSelected in
					if let trendingData = pageData as? TrendingCardData {
						trendingCardBuilder(data: trendingData, isSelected: isSelected)
					} else {
						Color.clear
							.frame(size: .zero)
					}
				}
            }
        }
		.frame(width: totalWidth, height: totalHeight, alignment: .top)
		.onReceive(viewModel.$data) { data in
			withAnimation(.default) {
				mainStates.loading = data.isEmpty
			}
		}
		.navigationTitle("")
		.navigationBarHidden(true)
		.fullScreenModal(isActive: $viewModel.showArt,
						 config: .init(isDraggable: true, showCloseIndicator: true),
						 innerContent: artInnerView)
        
    }
}
