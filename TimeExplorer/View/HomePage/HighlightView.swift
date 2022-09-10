//
//  HighlightView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 22/07/2021.
//

import SwiftUI
import SUI

struct HighlightView: View {
    var data:[AVSData]
    @StateObject var SP:swipeParams
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time:Int = 0
    init(data:[AVSData]){
        self.data = data
        self._SP = .init(wrappedValue: .init(0, data.count - 1, 50, type: .Carousel))
    }
    
    var offset:CGFloat{
        return self.SP.swiped > 0 ? -totalWidth : 0
    }
    
    func checkTime(){
        DispatchQueue.main.async {
			withAnimation(.linear(duration: 0.35)) {
				if self.time != 10{
					self.time += 1
				}else{
					self.time = 0
					self.SP.swiped  = self.SP.swiped + 1 < self.data.count ? self.SP.swiped + 1 : 0
				}
			}
        }
    }
    
    var body: some View {
		SlideOverCarousel(data: data){ viewData in
			if let artData = viewData as? AVSData {
				AuctionCard(idx: 0, data: artData, size: .init(width: .totalWidth - 10, height: 275))
			} else {
				Color.brown
			}
		}
		.onReceive(self.timer) { _ in self.checkTime()}
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView(data: Array(repeating: asm, count: 5))
    }
}
