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
		print("(DEBUG) loading card : \(data.mainText ?? "No Name")")
        self.data = data
		self._selectedArt = selectedArt
    }
    

	func infoView() -> some View{
        return VStack(alignment:.leading,spacing: 15){
			"Tours".normal(size: 40, color: .white).text
				.fillWidth(alignment: .leading)
            Spacer()
            BasicText(content: self.data.mainText ?? "", fontDesign: .serif, size: 30, weight: .bold)
                .foregroundColor(.white)
			"View"
				.normal(size: 17.5, color: .black)
				.text
				.blobify(background: .white, padding: 10, cornerRadius: 14)
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

