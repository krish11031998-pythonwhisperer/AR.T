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
	//TODO: - Add ArtTopFactView and ArtStockView
	
    var body:some View{
		StackedScroll(data: Array(0...1)) { data, isSelected in
			if let idx = data as? Int {
				if idx == 0 {
					ArtIntroMain(data: self.data)
				} else if idx == 1 {
					ArtView(data: self.data)
				}
			}
		}
    }
}
