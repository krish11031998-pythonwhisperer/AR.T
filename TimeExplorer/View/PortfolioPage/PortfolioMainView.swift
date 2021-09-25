//
//  PortfolioMainView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 16/07/2021.
//

import SwiftUI

struct PortfolioMainView: View {
    
    @State var paintings:[AVSData] = []
    @EnvironmentObject var mainStates:AppStates
//    @StateObject var artAPI:CAAPI = .init()
    @State var loadingText:String = "Loading..."
    @StateObject var SP:swipeParams = .init(100)
    
    func onAppear(){
        if let data = self.mainStates.getArt(limit: 50,skip: 400){
            self.parseData(data)
        }
    }
    
    func parseData(_ data:[CAData]){
        if !data.isEmpty{
            DispatchQueue.main.async {
                self.paintings = self.mainStates.CAAPI.artDatas.compactMap({AVSData(img: $0.images?.web?.url, title: $0.title, subtitle: $0.artistName, data: $0)})
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
            self.onReceive(data: data)
        }
       
    }
    
    let cardSize:CGSize = .init(width: totalWidth * 0.6, height: totalHeight * 0.5)
    
    func onReceive(data : [CAData]){
        if !data.isEmpty{
            DispatchQueue.main.async {
                self.loadingText = "Received..."
                
            }
            let paintings = data.compactMap({$0.images != nil ? AVSData(img: $0.images?.web?.url, title: $0.title, subtitle: $0.creators?.first?.description, data: $0) : nil})
            DispatchQueue.main.async {
                self.SP.start = 0
                self.SP.end = 4
                self.paintings = paintings
                self.loadingText = "Assigned!"
                if self.mainStates.loading{
                    self.mainStates.loading = false
                }
                
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            MainText(content: "On View", fontSize: 35, color: .white, fontWeight: .semibold)
                .padding()
                .frame(width: totalWidth, alignment: .leading)
            if !self.paintings.isEmpty{
                self.artScrollView
            }else{
                MainText(content: self.loadingText, fontSize: 25)
            }
            
        }
        .padding(.top,25)
        .frame(width: totalWidth, alignment: .leading)
//        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
        
    }
}


extension PortfolioMainView{
    var artScrollView:some View{
        VStack(alignment: .leading, spacing: 5){
            AVScrollView(attractions: Array(self.paintings[0..<5]),cardView: self.StockCard(_data:), leading: false)
                .environmentObject(self.SP)
                
            self.ArtDescriptionView
            MainText(content: "My Collection", fontSize: 35, color: .white, fontWeight: .semibold)
                .padding()
                .frame(width: totalWidth, alignment: .leading)
            PinterestScroll(data: Array(self.paintings[5...15]), equalSize: false)
            Spacer().frame(height: 250, alignment: .center)
        }.frame(width: totalWidth, alignment: .leading)
    }
    
    func StockCard(_data: EnumeratedSequence<[AVSData]>.Element) -> AnyView{
        let data = _data.element
        let idx = _data.offset
        return AnyView(GeometryReader{ g -> AnyView in
            let local = g.frame(in: .local)
            let selected = self.SP.swiped == idx
            let w = local.width
            let h = local.height
            let scale:CGFloat = selected ? 1.05 : 0.9
            
            let view = ZStack(alignment: .bottom) {
                ImageView(url: data.img, width: w, height: h, contentMode: .fill, alignment: .center)
                lightbottomShadow.frame(width: w + 1, alignment: .center)
                CurveChart(data: [45,25,10,60,30,79],interactions: false, size: .init(width: w * 0.75, height: h * 0.3),bg: AnyView(Color.clear),lineColor: .white,chartShade: false)
                        .frame(width: w, alignment: .leading)
                MainText(content: "250 BTC", fontSize: 15, color: .white, fontWeight: .regular)
                    .padding()
                    .frame(width: w, alignment: .trailing)
            }
            .clipShape(RoundedRectangle(cornerRadius: selected ? 20 : 10))
            .shadow(radius: selected ? 10 : 0)
            .scaleEffect(scale)
            .opacity(selected ? 1 : 0.2)
            .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))
            .onTapGesture {
                self.SP.swiped = idx
            }
            
            return AnyView(view)
            
        }.padding()
        .frame(width: self.cardSize.width , height: self.cardSize.height, alignment: .center))
    }
    
    var ArtDescriptionView : some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: self.paintings[self.SP.swiped].title ?? "Art#342", fontSize: 35, color: .white, fontWeight: .semibold)
                .fixedSize(horizontal: false, vertical: true)
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: totalHeight * 0.125, alignment: .topLeading)
            MainText(content: self.paintings[self.SP.swiped].subtitle ?? "Art#342", fontSize: 15, color: .white, fontWeight: .semibold)
            Spacer()
        }.padding()
        .frame(width: totalWidth,height: totalHeight * 0.25, alignment: .leading)
    }
    
    var chartView:some View{
        HStack(alignment: .center,spacing:10){
            WeekBarChart(header: "Views", values: [25,76,100,80,12,54,32])
            CircleChart(percent: 45, header: "Likes")
        }.padding(.horizontal)
        
    }
    
}


struct PortfolioMainView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioMainView()
    }
}
