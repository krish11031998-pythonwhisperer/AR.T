//
//  HomePage.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 28/05/2021.
//

import SwiftUI
import SUI

struct HomePageView: View {
    @EnvironmentObject var mainStates:AppStates
//    @StateObject var CAPI:ArtAPI = .init()
	@StateObject var viewModel = HomeViewModel()
    
    func header(dim:CGSize) -> some View{
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10, content: {
                    MainText(content: "Hi,", fontSize: 30, color: .white, fontWeight: .semibold, style: .normal)
                    MainText(content: "Krishna", fontSize: 45, color: .white, fontWeight: .semibold, style: .normal)
                })
                Spacer()
                ImageView(img: nil, width: totalWidth * 0.2, height: totalWidth * 0.2, contentMode: .fill, alignment: .center)
                    .clipShape(Circle())
            }.padding().frame(height: dim.height * 0.75, alignment: .center)
    }
    
	var posts: [AVSData] {
		viewModel.artworks
	}
    
    @ViewBuilder private func subView(section: HomeSection) -> some View {
		switch section {
		case .highlight:
			HighlightView(data: Array(self.posts[45..<50]), art: $viewModel.selectedArt)
		case .trending:
			TrendingArt(data: Array(self.posts[0..<10]))
		case .onRadar:
			OnRadarArt(data: Array(self.posts[20..<30]))
		case .recommended:
			RecommendArt(attractions: Array(self.posts[30..<40]))
		case .recent:
			BidArt(data: Array(self.posts[50..<60]))
		case .new:
			GenreView(genreData: Array(self.posts[40..<45]))
		case .artists:
			artistArtView(data: Array(self.posts[60...]))
		}
    }

	private var sections: [HomeSection] = [.highlight, .trending, .onRadar, .recommended, .recent, .new]
	
	private func onAppear() {
		if viewModel.artworks.isEmpty {
			viewModel.loadData()
		} else {
			asyncMainAnimation {
				mainStates.loading = false
			}
		}
	}
	
    var body: some View {
		ZStack(alignment: .center) {
			ScrollView(.vertical, showsIndicators: false){
				LazyVStack(alignment: .center, spacing: 10) {
					self.header(dim: .init(width: totalWidth, height: totalHeight * 0.35))
					if !self.posts.isEmpty {
						ForEach(sections, id:\.rawValue) { section in
							subView(section: section)
								.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
						}
					}
				}
				.fixedWidth(width: .totalWidth)
				.padding(.bottom, .safeAreaInsets.bottom + 100)
			}
			
			NavLink(isActive: $viewModel.showArt) {
				if let validSelectedArt = viewModel.selectedArt {
					ArtScrollMainView(data: validSelectedArt, showArt: $viewModel.showArt)
				} else {
					Color.clear.frame(size: .zero)
				}
				
			}
		}
		.background(Color.black)
        .edgesIgnoringSafeArea(.all)
		.onAppear(perform: onAppear)
		.onReceive(viewModel.$artworks) { output in
			asyncMainAnimation(animation: .easeInOut) {
				self.mainStates.loading = output.isEmpty
			}
		}
		.onChange(of: viewModel.showArt) { newValue in
			mainStates.showTab = !newValue
		}
		.navigationBarHidden(true)
    }
}

extension HomePageView{
    
    func BidArt(data: [AVSData])-> some View{
		let h: CGFloat = 250
		let w: CGFloat = 150
		let cardSize: CGSize = .init(width: w, height: h - 10)
		let rows = [GridItem.init(.adaptive(minimum: h - 10, maximum: h - 10), spacing: 10, alignment: .center)]
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, alignment: .center, spacing: 10) {
                ForEach(Array(data.enumerated()),id:\.offset) { elData in
					ArtViewCard(data: elData.element, cardSize: cardSize)
                }
            }
			.padding(.horizontal, 5)
            .frame(height:h * 2,alignment:.leading)
        }
    }
    
    func artistArtView(data:[AVSData]) -> some View{
        let f = Int(floor(Double(data.count/3)))
        let view = VStack(alignment: .center, spacing: 20) {
            ForEach(Array(0..<f),id: \.self) { i in
                let start = Int(i) * 3
                let end = Int(i + 1) * 3
                let arr_data = i == f ? Array(data[start...]) : Array(data[start..<end])

                ArtistArtView(data: arr_data)
                Divider().frame(width: totalWidth * 0.8, height: 5, alignment: .center)
            }
        }
        
        return view
    }
    
}



struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
