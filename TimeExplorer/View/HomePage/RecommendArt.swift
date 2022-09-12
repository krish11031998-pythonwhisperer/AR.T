//
//  AVScrollView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 19/05/2021.
//

import SwiftUI
import Combine
import SUI

struct AVSData{
    var img:String?
    var title:String?
    var subtitle:String?
    var data:Any?
}

struct RecommendArt: View {
    var data:[AVSData] = []
	init(attractions attr:[AVSData]){
		self.data = attr
	}
    
    let cardSize:CGSize = .init(width: 235, height: 350)

    var body: some View{
		SlideCardView(data: data, itemSize: cardSize, spacing: 0, leading: false) { data, selected in
			if let data = data as? AVSData {
				ZStack(alignment: .bottom) {
					SUI.ImageView(url: data.img)
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
			} else {
				Color.orange
					.framed(size: cardSize, cornerRadius: 12, alignment: .center)
			}
			
		}

    }
}

//struct AVScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        AVScrollView()
//    }
//}
