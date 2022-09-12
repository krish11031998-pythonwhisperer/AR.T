//
//  ArtScrollMainView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 03/05/2021.
//

import SwiftUI
import SUI

struct ArtScrollMainView: View {
    @EnvironmentObject var mainStates:AppStates
    var data:ArtData
    @Binding var showArt:Bool
    @State var minY:CGFloat = 0
    @State var swiped:Int = 0
    @State var offset:CGFloat = 0
    @State var changeFocus:Bool = false
    
	var exampleView: some View {
		VStack(alignment: .leading, spacing: 20) {
			RoundedButton(model: .testModel)
				.fixedSize(horizontal: false, vertical: true)
				.clipped()
			RoundedButton(model: .testModelLeading)
				.fixedSize(horizontal: false, vertical: true)
				.clipped()
			RoundedButton(model: .testModelTrailing)
				.fixedSize(horizontal: false, vertical: true)
				.clipped()
			RoundedButton(model: .testModelWithBlob)
				.fixedSize(horizontal: false, vertical: true)
		}
		.padding(.init(top: .safeAreaInsets.top + 50, leading: 20, bottom: .safeAreaInsets.bottom, trailing: 20))
		.frame(width: .totalWidth, height: .totalHeight, alignment: .topLeading)
		
	}
	
	//TODO: - Add ArtTopFactView and ArtStockView
	
    var body:some View{
		StackedScroll(data: Array(0...1)) { data, isSelected in
			if let idx = data as? Int {
				if idx == 0 {
					ArtIntroMain(data: self.data)
				} else if idx == 1 {
					ArtView(data: self.data)
				}
			} else {
				exampleView
			}
		}
    }
}
