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
				
				Group {
					intoInfosection()
					infoBody(w: .totalWidth)
				}
				.padding()
				.fillWidth(alignment: .topLeading)
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
		ZStack(alignment: .center) {
			Color.clear
			BlurView(style: .dark)
			ScrollView(.vertical, showsIndicators: false) {
				MainText(content: self.data.introduction, fontSize: 25, color: .white, fontWeight: .semibold)
					.lineLimit(Int.max)
					.padding()
					.padding(.top,.safeAreaInsets.top)
			}.fillFrame()
			CustomButton(config: .init(imageName: .back, size: .init(squared: 15), padding: .init(by: 5), foregroundColor: .white, backgroundColor: .clear)) {
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
				.lineLimit(3)
			CustomButton(config: .init(imageName: .next, size: .init(squared: 15), padding: .init(by: 5), foregroundColor: .white, backgroundColor: .clear)) {
				showMore = true
			}
        }
		.fillHeight(alignment: .bottomLeading)
    }
    
	@ViewBuilder func intoInfosection() -> some View {
		if let validInfoSnippet = data.infoSnippets {
			LazyVGrid(columns:Array(repeating: .init(.flexible(minimum: .totalWidth * 0.25, maximum: .totalWidth *  0.5 - 5), spacing: 10, alignment: .topLeading),count: 2), alignment: .leading, spacing: 10) {
				ForEach(validInfoSnippet.map{ $0 }.sorted { $0.key < $1.key }, id: \.key) {
					HeaderSubHeadView(title: $0.key.normal(size: 14,color: .gray),
									  subTitle: $0.value.normal(size: 16, color: .white),
									  spacing: 8,
									  alignment: .leading)
				}
			}
			.fixedSize(horizontal: false, vertical: true)
		} else {
			Color.clear.frame(size: .zero)
		}
	}
}



struct ScrollInfoCard_Preview:PreviewProvider{
    static var previews: some View{
        ArtIntroMain(data: test)
            .edgesIgnoringSafeArea(.all)
    }
}
