//
//  TrendingCard.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 11/03/2021.
//

import SwiftUI
import AVKit
import SUI

struct TrendingMainCard:View{
    var idx:Int?
    var data:TrendingCardData
	@Binding var selectedArt: TrendingCardData?
    var isViewing:Bool = false
    
	init(_ data:TrendingCardData, selectedArt: Binding<TrendingCardData?>) {
        self.data = data
		self._selectedArt = selectedArt
    }
    

	func infoView() -> some View{
        return VStack(alignment:.leading,spacing: 15){
			"Tours".heading1().text
				.fillWidth(alignment: .leading)
            Spacer()
            (data.mainText ?? "No Name").heading2().text
			"View"
                .body2Medium(color: .black)
				.text
                .padding(.init(vertical: 10, horizontal: 10))
                .background {
                    Capsule(style: .continuous)
                        .fill(Color.white)
                }
				.buttonify {
					selectedArt = data
				}
        }
		.padding(.horizontal,25)
		.padding(.top, .safeAreaInsets.top)
		.padding(.bottom, .safeAreaInsets.bottom)

    }
    
	var body: some View{
		ZStack{
			SUI.ImageView(url: data.image)
				.framed(size: .init(width: .totalWidth, height: .totalHeight), cornerRadius: 0, alignment: .center)
			bottomShadow
			self.infoView()
				.padding(.bottom,100)
		}
		.framed(size: .init(width: .totalWidth, height: .totalHeight), cornerRadius: 0, alignment: .center)
	}

}

