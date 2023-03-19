//
//  MuseumSpecial.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 19/09/2022.
//

import SwiftUI
import SUI

private enum MuseumSpecialSection: String, Codable, CaseIterable {
	case female_artists = "Female Artists"
	case alumni = "Alumni Artists"
	case mayShow = "May Show"
}

extension MuseumSpecialSection {
	
	var searchParam: SearchParam {
		switch self {
		case .female_artists:
			return .init(female_artists: true)
		case .alumni:
			return .init(cia_alumni_artists: true)
		case .mayShow:
			return .init(may_show_artists: true)
		}
	}
}


struct MuseumSpecial: View {
	
	@EnvironmentObject var homeViewModel: HomeViewModel
	@State private var selectedSection: MuseumSpecialSection = .female_artists
	let currentSection: HomeSection
	
	init(currentSection: HomeSection = .museumSpecials) {
		self.currentSection = currentSection
	}
	
	var data: [CAData] {
		homeViewModel.sectionData[currentSection] as? [CAData] ?? []
	}
	
	
	private func selectedConfig(_ section: MuseumSpecialSection) -> BlobButtonConfig {
		.init(color: (selectedSection == section ? Color.purple : Color.white).opacity(0.15),
			  cornerRadius: 12, border: .init(color: selectedSection == section ? Color.purple : Color.white, borderWidth: 1.25))
	}
	
	private var section: some View {
		SimpleHScroll(data: MuseumSpecialSection.allCases, config: .init(spacing: 10,
                                                                         showsIndicator: false,
                                                                         horizontalInsets: .zero,
                                                                         alignment: .center)) { section in
            BlobButton(text: section.rawValue.styled(font: .mediumItalic,color: .white, size: 13), config: selectedConfig(section)) {
				withAnimation {
					selectedSection = section
					homeViewModel.loadDataForSection(section: currentSection, param: section.searchParam)
				}
			}
		}
	}
	
	private var artSection: some View{
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 8) {
                ForEach(data, id: \.id) { artData in
                    ArtViewCard(data: artData, cardSize: .init(width: 200, height: 250))
                }
            }
        }
	}
	
    var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			section
			artSection
        }.padding(.horizontal, 16)
    }
}
