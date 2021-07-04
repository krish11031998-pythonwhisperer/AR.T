//
//  LocView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 13/06/2021.
//

import SwiftUI

struct SummaryView: View {
    var header:String
    var size:CGSize = .init(width: totalWidth * 0.9, height: totalHeight * 0.35)
    var data:[String:Int]
    init(header:String,size:CGSize? = nil,data:[String:Int] = ["Reshares":653,"Bids":25," Highest Bid": 500,"Ads" : 10]) {
        self.header = header
        if let safeSize = size{
            self.size = safeSize
        }
        self.data = data
    }
    
    func mainBody(w:CGFloat,h:CGFloat) -> AnyView{
        let col = [GridItem(.adaptive(minimum: w * 0.5, maximum: w * 0.5), spacing: 0, alignment: .center)]
        
        return AnyView(
            LazyVGrid(columns: col, alignment: .center, spacing: 0){
                ForEach(Array(self.data.keys.enumerated()),id: \.offset){ _key in
                    let key = _key.element
                    let val = self.data[key] ?? 0
                    VStack(alignment: .leading, spacing: 5){
                        MainText(content: "\(val)", fontSize: 60, color: .white, fontWeight: .regular)
                        MainText(content: key, fontSize: 15, color: .white, fontWeight: .thin)
                        Spacer()
                    }.padding()
                    .frame(width:w * 0.5,height: h * 0.45, alignment: .leading)
                }
            }
        )
    }
    
    var body: some View {
        ChartCard(header: self.header, size: self.size,insideView: self.mainBody)
    }
}

struct LocView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(header: "Stats")
    }
}
