//
//  AVScrollView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 19/05/2021.
//

import SwiftUI
import Combine
import SUI

//struct AVSData{
//    var img:String?
//    var title:String?
//    var subtitle:String?
//    var data:Any?
//}

struct RecommendArt: View {
	@EnvironmentObject var homePage: HomeViewModel
    var data:[CAData] = []
	init(attractions attr:[CAData]){
		self.data = attr
	}
    
    let cardSize:CGSize = .init(width: 235, height: 350)

	func action(_ artData: CAData) {
		homePage.selectedArt = .init(id: "\(artData.id ?? 0)", date: .now, title: artData.title ?? "", model_url: nil, introduction: artData.digital_description ?? artData.wall_description ?? ""
						 , painterName: artData.artistName ?? "", painterImg: artData.title ?? "", top_facts: nil, thumbnail: artData.thumbnail)
	}
	
    var body: some View{
		SlideCardView(data: data, itemSize: cardSize, leading: false, action: action(_:)) { data, selected in
			ZStack(alignment: .bottom) {
				SUI.ImageView(url: data.thumbnail)
					.framed(size: cardSize, cornerRadius: 0, alignment: .center)
				if selected {
					lightbottomShadow.fillFrame()
					(data.title ?? "No Heading")
						.normal(size: 15)
						.text
						.fillWidth(alignment: .leading)
						.transitionFrom(.bottom)
						.padding()
				}
			}
			.framed(size: cardSize, cornerRadius: 12, alignment: .bottomLeading)
		}

    }
}

//struct AVScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        AVScrollView()
//    }
//}
