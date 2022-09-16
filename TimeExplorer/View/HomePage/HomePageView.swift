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
    
	var posts: [CAData] {
		viewModel.artworks
	}
    
    @ViewBuilder private func subView(section: HomeSection) -> some View {
		if let data = viewModel.sectionData[section] {
			switch section {
			case .highlight:
				HighlightView(data: data as? [CAData] ?? [])
					.environmentObject(viewModel)
					.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
			case .currentlyOnView:
				TrendingArt(data: data as? [CAData] ?? [])
					.environmentObject(viewModel)
					.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
			case .onRadar:
				OnRadarArt(data: data as? [CAData] ?? [])
					.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
			case .mayShow:
				ArtDepartmentView(data: data as? [CAData] ?? [])
					.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
			case .recent:
				RecommendArt(attractions: data as? [CAData] ?? [])
					.environmentObject(viewModel)
					.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
			case .new:
				GenreView(genreData: data as? [CAData] ?? [])
					.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
			case .artists:
				artistArtView(data: data as? [CAData] ?? [])
					.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
			case .departments:
				departmentView
			case .types:
				typesView
					.containerize(title: section.rawValue.normal(size: 24), vPadding: 0, hPadding: 10)
			}
		} else {
			Color.gray.opacity(0.15)
				.framed(size: .init(width: .totalWidth - 10, height: 300))
		}
    }

	private var sections: [HomeSection] = HomeSection.allCases  //[.highlight, .trending, .onRadar, .recommended, .recent, .new]

    var body: some View {
		ZStack(alignment: .center) {
			ScrollView(.vertical, showsIndicators: false){
				LazyVStack(alignment: .center, spacing: 10) {
					self.header(dim: .init(width: totalWidth, height: totalHeight * 0.35))
					ForEach(sections, id:\.rawValue) { section in
						subView(section: section)
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
			
			NavLink(isActive: $viewModel.showDepartments) {
				DepartmentView(department: viewModel.selectedDepartment ?? .contemporary)
			}
		}
		.background(Color.black)
        .edgesIgnoringSafeArea(.all)
		.onAppear { mainStates.loading = !viewModel.finishedLoading }
		.onChange(of: viewModel.finishedLoading) { mainStates.loading = !$0}
		.onChange(of: viewModel.showArt) { mainStates.showTab = !$0 }
		.navigationBarHidden(true)
    }
}

extension HomePageView{
    
    func BidArt(data: [CAData])-> some View{
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
    
    func artistArtView(data:[CAData]) -> some View{
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
    
	var departmentView: some View {
		VStack(alignment: .leading, spacing: 10) {
			"Departments".normal(size: 25).text
				.padding()
			Spacer()
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(alignment: .center, spacing: 8) {
					ForEach(Array(Department.allCases[0..<Department.allCases.count/2]), id: \.rawValue) { data in
						BlobButton(text: data.rawValue.normal(size: 16, color: .white), config: viewModel.blobConfig) {
							viewModel.selectedDepartment = data
						}
					}
				}.padding(.horizontal)
				.fillWidth(alignment: .leading)
				
				HStack(alignment: .center, spacing: 8) {
					ForEach(Array(Department.allCases[Department.allCases.count/2..<Department.allCases.count]), id: \.rawValue) { data in
						BlobButton(text: data.rawValue.normal(size: 16, color: .white), config: viewModel.blobConfig) {
							viewModel.selectedDepartment = data
						}
					}
				}.padding(.horizontal).fillWidth(alignment: .leading)
			}
			.padding(.bottom)
		}
		.fixedHeight(height: 250)
		.background(Color.purple.opacity(0.15).clipShape(RoundedRectangle(cornerRadius: 20)))
		.borderCard(borderColor: .purple, radius: 20, borderWidth: 1.25)
	}

	
	var typesView: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(alignment: .center, spacing: 8) {
				ForEach(Types.allCases, id: \.rawValue) { dpt in
					VStack(alignment: .leading, spacing: 0) {
						dpt.rawValue.systemBody(color: .white).text
							.fillFrame(alignment: .bottomLeading)
					}
					.padding()
					.background(Color.purple.opacity(0.05))
					.framed(size: .init(width: 125, height: 175))
					.borderCard(borderColor: .purple.opacity(0.35), radius: 16, borderWidth: 1)
				}
			}
		}
	}

	
}



struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
