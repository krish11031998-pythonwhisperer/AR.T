//
//  BlurView.swift
//  SUI
//
//  Created by Krishna Venkatramani on 11/09/2022.
//

import SwiftUI

struct BlurView:UIViewRepresentable{
	var style : UIBlurEffect.Style
	
	func makeUIView(context: Context) -> UIVisualEffectView {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: self.style))
		return view
	}
	
	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
		
	}
}
