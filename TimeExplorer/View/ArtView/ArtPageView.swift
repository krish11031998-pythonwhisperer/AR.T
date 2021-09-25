//
//  ArtPageView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 07/05/2021.
//

import SwiftUI

struct ArtPageView: View {
    var data:ArtData
    var onChanged:(DragGesture.Value) -> Void
    var onEnded:(DragGesture.Value) -> Void

    func biddingInfo(w:CGFloat,h:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            HeadingInfoText(heading: "Current Bid", subhead: "5999 ETH", headingSize: 15, headingColor: .gray, headingDesign: .serif, subheadSize: 18, subheadColor: .white, subheadDesign: .monospaced)
            Spacer()
            HeadingInfoText(heading: "Date: 15th May", subhead: "Place a bid  ->", headingSize: 15, headingColor: .white, headingDesign: .monospaced, subheadSize: 15, subheadColor: .black, subheadDesign: .serif, haveBG: true)
                .background(Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 20))
                .clipShape(Rectangle())
                .offset(y: -h * 0.075)
        }.padding()
        .frame(width: w, height: h * 0.15, alignment: .center)
    }
    
    func sellerInfo(name:String,w:CGFloat,h:CGFloat) -> some View{
        return VStack(spacing: 1.5){
            HStack(alignment: .center, spacing: 10) {
                ImageView(img: nil, width: w * 0.1, height:  h * 0.35, contentMode: .fit, alignment: .center)
                    .clipShape(Circle())
                MainText(content: name, fontSize: 13, color: .white, fontWeight: .semibold, style: .normal)
                Spacer()
                SystemButton(b_name: "ellipsis", b_content: "", color: .black, haveBG: true, bgcolor: .white) {
                    print("More Options Pressed")
                }
            }.padding(.horizontal)
            Divider().background(Color.white).padding().frame(width: w)
        }.frame(width: w, height: h, alignment: .center)
    }
    
    var body: some View {
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            VStack(alignment: .leading, spacing: 0) {
                ImageView(url: self.data.thumbnail, width: totalWidth, height: h * 0.5, contentMode: .fill, alignment: .top)
                self.biddingInfo(w: w, h: h)
                
                self.sellerInfo(name: "Krishna Venkatramani", w: w, h: h * 0.15)
                
                Spacer()
            }.frame(width: w, height: h, alignment: .center)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .background(Color.black)
        .gesture(DragGesture()
                    .onChanged(self.onChanged)
                    .onEnded(self.onEnded))
    }
}

struct ArtPageView_Previews: PreviewProvider {
    static func onChanged(value:DragGesture.Value){
        print("Drag Started")
    }
    static func onEnded(value:DragGesture.Value){
        print("Drag Ended")
    }
    static var previews: some View {
        ArtPageView(data: test,onChanged: ArtPageView_Previews.onChanged(value:),onEnded: ArtPageView_Previews.onEnded(value:))
    }
}
