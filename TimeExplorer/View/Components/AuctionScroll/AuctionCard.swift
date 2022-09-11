//
//  AuctionCard.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 19/06/2021.
//

import SwiftUI
import SUI

enum AuctionCardStyling {
	case rounded(CGFloat)
	case original
}

extension AuctionCardStyling {
	
	var cornerRadius: CGFloat {
		switch self {
		case .rounded(let radius):
			return radius
		case .original:
			return 0
		}
	}
}

struct AuctionCard: View {
    var data:AVSData = .init()
	let cardStyling: AuctionCardStyling
    var cardSize:CGSize = .init()
	@State var pct: CGFloat = 0
    
	init(data:AVSData,
		 styling: AuctionCardStyling = .original,
		 size:CGSize = .init(width: totalWidth - 20, height: totalHeight * 0.4)
	){
		self.cardStyling = styling
        self.data = data
        self.cardSize = size
    }
    
    var overlayCaptionView:some View{
		VStack(alignment: .leading, spacing: 10){
			ownerInfo
			Spacer()
			MainText(content: self.data.title ?? "Title", fontSize: 20, color: .white, fontWeight: .regular)
			lineChart(h: 10)
			cardInfo
		}.padding()
		.framed(size: cardSize, cornerRadius: .zero, alignment: .topLeading)
    }
    
	var body: some View {
		ZStack(alignment: .center) {
			SUI.ImageView(url: data.img)
			lightbottomShadow.fillFrame()
			overlayCaptionView
		}
		.framed(size: cardSize, cornerRadius: cardStyling.cornerRadius, alignment: .center)
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				withAnimation(.default) {
					self.pct = 0.5
				}
			}
		}
	}
}

extension AuctionCard{
    
    func lineChart(h line_h:CGFloat) -> some View{
		RoundedRectangle(cornerRadius: 10)
			.fill(Color.gray.opacity(0.2))
			.horizontalProgressBar(pct: pct, lineColor: .white, size: .init(width: cardSize.width - 30, height: line_h))
			.fillWidth()
			.fixedHeight(height: line_h)
    }
    
	var cardInfo: some View{
        HStack(alignment: .center, spacing: 10){
            BasicText(content: "\(5999) BTC", fontDesign: .monospaced, size: 20, weight: .bold)
                .foregroundColor(.white)
            Spacer()
            MainText(content: "30 bids", fontSize: 20, color: .white, fontWeight: .regular)
        }
		.fixedSize(horizontal: false, vertical: true)
    }
    
	var ownerInfo: some View{
        HStack(alignment: .center, spacing: 10){
            Circle()
				.fill(Color.black)
				.framed(size: .init(squared: 20), cornerRadius: 10, alignment: .center)
            MainText(content: self.data.subtitle ?? "Krishna", fontSize: 15, color: .white, fontWeight: .semibold)
            Spacer()
        }
		.fixedSize(horizontal: false, vertical: true)
    }
    
}

struct AuctionCard_Previews: PreviewProvider {
    static var previews: some View {
        AuctionCard(data: .init(img: test.thumbnail, title: test.title, subtitle: test.painterName, data: test))
    }
}
