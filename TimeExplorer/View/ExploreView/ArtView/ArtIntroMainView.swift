//
//  ArtIntroMainView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 08/05/2021.
//

import SwiftUI
import SUI

struct ArtIntroMain:View{
    var data:ArtData
    @State var showMore:Bool = false
    @Namespace var animation
    init(data:ArtData){
        self.data = data
		let navigationBarAppearance = UINavigationBarAppearance()
		navigationBarAppearance.configureWithTransparentBackground()
		UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
		UINavigationBar.appearance().standardAppearance = navigationBarAppearance
		UINavigationBar.appearance().compactAppearance = navigationBarAppearance
	}
    
    func infoOverlay(w:CGFloat,h:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10){
            Spacer()
            ScrollView(.vertical, showsIndicators: false) {
                HeadingInfoText(heading: self.data.title, subhead: "1503 - 1506", headingSize: 35, headingColor: .white, headingDesign: .serif, subheadSize: 20, subheadColor: .white, subheadDesign: .rounded)
                    .frame(width: w * 0.5, alignment: .leading)
            }.frame(height: h * 0.35, alignment: .center)
            
        }.padding()
        .padding(.leading)
        .frame(width: w, height: h, alignment: .bottomLeading)
    }
    
	var body: some View{
		ZStack(alignment:.top){
			Color.black
			VStack(alignment: .leading, spacing: 20){
				ZStack(alignment: .bottom) {
					SUI.ImageView(url: data.thumbnail)
						.framed(size: .init(width: .totalWidth, height: .totalHeight * 0.45),cornerRadius: 0,alignment: .top)
					lightbottomShadow.fillFrame()
					HeaderSubHeadView(title: data.title.normal(size: 30),
									  subTitle: data.painterName?.normal(size: 20),
									  spacing: 10, alignment: .leading)
					.padding(.leading, 10)
					.fillWidth(alignment: .leading)
						
				}.framed(size: .init(width: .totalWidth, height: .totalHeight * 0.45),cornerRadius: 0)
				
				//self.introInfoSection(w: .totalWidth, h: .totalHeight * 0.25)
				self.infoBody(w: .totalWidth)
			}
			if showMore {
				extraIntroView
					.transitionFrom(.bottom)
			}
		}
		.framed(size: .init(width: .totalWidth, height: .totalHeight), cornerRadius: 0, alignment: .topLeading)
		.scrollToggle(state: !showMore)
	}
    
}

extension ArtIntroMain{
	@ViewBuilder var extraIntroView : some View{
		let w = CGFloat.totalWidth
		let h = CGFloat.totalHeight
		ZStack(alignment: .center) {
			Color.clear
			BlurView(style: .dark)
			ScrollView(.vertical, showsIndicators: false) {
				MainText(content: self.data.introduction, fontSize: 25, color: .white, fontWeight: .semibold)
					.lineLimit(Int.max)
					.padding()
					.padding(.top,.safeAreaInsets.top)
			}.fillFrame()
			CustomButton(config: .init(imageName: .back, size: .init(squared: 15), padding: 5, foregroundColor: .white, backgroundColor: .clear)) {
				showMore = false
			}
			.padding(.horizontal,20)
			.padding(.bottom)
			.fillFrame(alignment: .bottomLeading)
		}
		.frame(width: .totalWidth, height: .totalHeight, alignment: .topLeading)
		.edgesIgnoringSafeArea(.all)
	}

    func infoBody(w:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10){
			data.introduction.normal(size: 15).text
				.padding(.horizontal,5)
			CustomButton(config: .init(imageName: .next, size: .init(squared: 15), padding: 5, foregroundColor: .white, backgroundColor: .clear)) {
				showMore = true
			}
        }.padding()
        .frame(width: w,alignment: .topLeading)
    }
    
//    func introInfoSection(w:CGFloat,h:CGFloat) -> some View{
//        HStack(alignment: .center, spacing: 10) {
//            VStack(alignment: .center, spacing: 10){
//				SUI.ImageView(url: data.painterImg)
//					.fixedWidth(width: w * 0.45)
//					.fillHeight(alignment: .center)
//					.clipContent(radius: 20)
//				(data.painterName ?? "Artisan").normal(size: 20).text
//            }.padding(.leading, 20)
//            Spacer()
//            if self.data.infoSnippets != nil{
//                VStack(alignment: .leading, spacing: 10){
//					ForEach(Array(self.data.infoSnippets!.keys).sorted(),id:\.self) { key in
//                        let value = self.data.infoSnippets![key] ?? "No Info"
//						HeaderSubHeadView(title: key.normal(size: 15, color: .gray),
//										  subTitle: value.normal(size: 18, color: .white),
//										  spacing: 0,
//										  alignment: .leading)
//                    }
//                }
//                Spacer()
//            }
//		}.framed(size: .init(width: w, height: h), cornerRadius: 0, alignment: .leading)
//		VStack(alignment: .leading, spacing: 5) {
//			<#code#>
//		}
//    }
	
//	var infoKeyValue: [(key:String, value:String?)] {
//		[(key: "Creation Date", value: data.date),
//		 (key: "Origin", value: data.[])
//		]
//	}
}



struct ScrollInfoCard_Preview:PreviewProvider{
    static var previews: some View{
        ArtIntroMain(data: test)
            .edgesIgnoringSafeArea(.all)
    }
}
