//
//  RecommendArt.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 04/06/2021.
//

import SwiftUI

struct RecommendArt: View {
    var data:[AVSData] = []
    @EnvironmentObject var mainStates:AppStates
    @StateObject var IMD:ImageDownloader
    var tabSize:CGSize = .init(width: totalWidth * 0.7, height: totalHeight * 0.3)
    
    init(data:[AVSData]){
        self.data = data
        self._IMD = StateObject(wrappedValue: .init(urls: data.compactMap({$0.img}), mode: "multiple", quality: .low))
    }
    
    func card(idx:Int) -> AnyView{
        var view = AnyView(Color.clear)
        if idx < self.data.count{
            let data = self.data[idx]
            view = AnyView(
                GeometryReader{g in
                    let w = g.frame(in: .local).width
                    let h = g.frame(in: .local).height
                    HStack(alignment: .bottom, spacing: 15){
                        ImageView(url: data.img, width: w * 0.4, height: h, contentMode: .fill, alignment: .bottom,clipping: .roundClipping)
//                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        VStack(alignment: .leading, spacing: 10) {
                            MainText(content: data.title ?? "", fontSize: 15, color: .white,fontWeight: .regular, style: .normal)
                            MainText(content: "Bidding Price", fontSize: 12.5, color: .gray,fontWeight: .semibold, style: .normal)
                            MainText(content: "3 BTC", fontSize: 13, color: .white,fontWeight: .bold, style: .normal)
                        }.padding(.vertical)
                        Spacer()
                    }.frame(width: w, height: h, alignment: .center)
                }.padding()
                .frame(width: tabSize.width, height: tabSize.height * 0.5,alignment: .center)
            )
        }
        return view
    }
    
    
    var grid:some View{
        let h = (tabSize.height * 0.5 - 5)
        let row = [GridItem(.adaptive(minimum: h, maximum: h), spacing: 0)]
        return LazyHGrid(rows: row, alignment: .center, spacing: 10) {
            ForEach(Array(self.data.enumerated()),id:\.offset) { _data in
                let data = _data.element
                let idx = _data.offset
                self.card(idx: idx)
                    .buttonify {
                        self.mainStates.updateSelectedArt(data: data.data)
                    }
            }
        }.frame(height: tabSize.height, alignment: .leading)
    }
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
//            if !self.IMD.loading && self.IMD.images.count > 0{
                self.grid
//            }
        }
    }
}

//struct RecommendArt_Previews: PreviewProvider {
//    static var previews: some View {
//        RecommendArt()
//    }
//}
