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
//            case .tour:
//                guard let data = _data.data as? TourData else {return res}
//                res = .init(image: data.mainImage, username: data.user, mainText: data.mainTitle, type: .tour,data:data,location:data.location,date:data.date ?? Date())
//            case .blog:
//                guard let data = _data.data as? BlogData else {return res}
//                res = .init(image: data.image?.first, username: data.user, mainText: data.headline, type: .blog,data:data,date:data.date ?? Date())
//            case .post:
//                guard let data = _data.data as? PostData else {return res}
//                res = .init(image: data.image?.first, vid_url: data.video?.first, username: data.user, mainText: data.caption, type: .post,data:data,date:data.date ?? Date())
            case .art:
                guard let data = _data.data as? ArtData else {return res}
			res = .init(image: data.thumbnail, vid_url:data.main_vid_url, mainText: data.title, type: .art, data: data,date: .now)
        }
        return res
    }
}

struct TrendingMainView: View {
    @State var data:[TrendingCardData] = []
    @EnvironmentObject var mainStates:AppStates
    @State var showArt:Bool = false
	@State var currentCard: TrendingCardData? = nil

    func onAppear(){
        self.mainStates.loading = true
        if !self.mainStates.showTab{
            self.mainStates.showTab = true
        }
        self.downloadArtPainting()
    }
    
    func getCAAPIData(){
        if let data = self.mainStates.getArt(limit: 100,skip: 100){
            self.parseData(data)
        }
    }
    
    func downloadArtPainting(){
        if self.mainStates.AAPI.arts.isEmpty{
            self.mainStates.AAPI.getArts(_name: self.mainStates.userAcc.username)
        }else{
            self.receiveArt(arts: self.mainStates.AAPI.arts)
        }
        self.getCAAPIData()
    }

    func receiveArt(arts:[ArtData]){
        if !arts.isEmpty{
            let _art = arts.compactMap({$0.parseVisualData()})
            DispatchQueue.main.async {
                self.data = _art
            }
        }
    }
    
    
    
    func parseData(_ data:[CAData]){
        
        if !data.isEmpty{
            let _data = data.compactMap({ TrendingCardData(image: $0.thumbnail, username: $0.artistName, mainText: $0.title, type: .art, data: ArtData(date: Date(), title:$0.title ?? "No Title", introduction: $0.wall_description ?? "Description",infoSnippets: $0.PaintingInfo, painterName: $0.artistName, thumbnail: $0.thumbnail,model_img: $0.original), date: Date())})
            DispatchQueue.main.async {
                self.data.append(contentsOf: _data)
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
        }
       
    }
    

    func updateViewState(){
        self.showArt.toggle()
    }


	func trendingCardBuilder(data: TrendingCardData, isSelected: Bool) -> some View {
		if isSelected {
			DispatchQueue.main.async {
				currentCard = data
			}
		}
		return TrendingMainCard(data, handler: updateViewState)
		
	}
	
	var paginatedData: [TrendingCardData] {
		return data.count > 20 ? Array(data[0...20]) : data
	}
	
    func ContentScroll(w:CGFloat,h:CGFloat) -> some View{

		StackedScroll(data: paginatedData) { pageData, isSelected in
			if let trendingData = pageData as? TrendingCardData {
				trendingCardBuilder(data: trendingData, isSelected: isSelected)
			} else {
				Color.clear
					.frame(size: .zero)
			}
		}
    }
    
	@ViewBuilder func artInnerView() -> some View {
		if let data = self.currentCard?.data as? ArtData,self.showArt {
			ArtScrollMainView(data: data,showArt: $showArt)
				.environmentObject(self.mainStates)
		} else {
			Color.black
				.framed(size: .init(width: .totalWidth, height: .totalHeight), cornerRadius: 0, alignment: .center)
		}
	}

    var body: some View {
        ZStack(alignment:.top){
            Color.black
            if !self.data.isEmpty && !self.mainStates.loading{
				StackedScroll(data: paginatedData) { pageData, isSelected in
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
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.AAPI.$arts, perform: self.receiveArt(arts:))
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
		.fullScreenModal(isActive: $showArt, config: .init(isDraggable: true, showCloseIndicator: true), innerContent: artInnerView)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}
