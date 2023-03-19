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

struct AuctionCardConfig {
	struct Bid {
		let bids: Int
		let price: Int
		let currency: String
	}
	
	let bids: Bid?
	let showBar: Bool
	let cardStyling: AuctionCardStyling
	let cardSize: CGSize
}

extension AuctionCardConfig.Bid {
	
	static var test: Self { .init(bids: 30, price: 50, currency: "BTC")}
}

struct AuctionCard: View {
    let data:CAData
	let cardConfig: AuctionCardConfig
	@State var pct: CGFloat = 0
    
	init(data:CAData,
		 cardConfig: AuctionCardConfig
	){
		self.cardConfig = cardConfig
        self.data = data
    }
    
    var overlayCaptionView:some View{
		VStack(alignment: .leading, spacing: 10){
			Spacer()
            (self.data.title ?? "Title").body1Bold(color: .white).text.lineLimit(3)
			lineChart(h: 10)
			cardInfo
		}
        .padding()
		.framed(size: cardConfig.cardSize, cornerRadius: .zero, alignment: .leading)
    }
    
	var body: some View {
		ZStack(alignment: .center) {
			SUI.ImageView(url: data.thumbnail)
				.framed(size: cardConfig.cardSize, cornerRadius: 0, alignment: .top)
			lightbottomShadow.fillFrame()
			overlayCaptionView
		}
		.framed(size: cardConfig.cardSize, cornerRadius: cardConfig.cardStyling.cornerRadius, alignment: .top)
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
    
    @ViewBuilder func lineChart(h line_h:CGFloat) -> some View{
		if cardConfig.showBar {
			RoundedRectangle(cornerRadius: 10)
				.fill(Color.gray.opacity(0.2))
				.horizontalProgressBar(pct: pct, lineColor: .white)
				.fillWidth()
				.fixedHeight(height: line_h)
		} else {
            CustomDivider()
            (self.data.creators?.first?.description ?? "Krishna").styled(font: .mediumItalic, color: .white, size: 14).text
		}
		
    }
    
	@ViewBuilder var cardInfo: some View{
		if let validBidInfo = cardConfig.bids {
			HStack(alignment: .center, spacing: 10){
				BasicText(content: "\(validBidInfo.price) \(validBidInfo.currency)", fontDesign: .monospaced, size: 20, weight: .bold)
					.foregroundColor(.white)
				Spacer()
				MainText(content: "\(validBidInfo.bids) bids", fontSize: 20, color: .white, fontWeight: .regular)
			}
			.fixedSize(horizontal: false, vertical: true)
		} else {
			EmptyView().body
		}
        
    }
    
	var ownerInfo: some View{
        HStack(alignment: .center, spacing: 10){
            Circle()
				.fill(Color.black)
				.framed(size: .init(squared: 20), cornerRadius: 10, alignment: .center)
			MainText(content: self.data.creators?.first?.description ?? "Krishna", fontSize: 15, color: .white, fontWeight: .semibold).lineLimit(1)
            Spacer()
        }
		.fixedSize(horizontal: false, vertical: true)
    }
    
}

//struct AuctionCard_Previews: PreviewProvider {
//    static var previews: some View {
//		AuctionCard(data: .init(img: test.thumbnail, title: test.title, subtitle: test.painterName, data: test),
//					cardConfig: .init(bids: .test, showBar: true, cardStyling: .rounded(14), cardSize: .init(width: 200, height: 300)))
//    }
//}
