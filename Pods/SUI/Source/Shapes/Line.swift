//
//  Line.swift
//  SUI
//
//  Created by Krishna Venkatramani on 15/09/2022.
//

import SwiftUI

struct Line: Shape {
	
	let pct: CGFloat
	
	public init(pct: CGFloat) {
		self.pct = pct
	}
	
	public func path(in rect: CGRect) -> Path {
		var p = Path()
		
		p.addRect(.init(origin: rect.origin, size: .init(width: rect.width * pct, height: rect.height)))
		
		return p
	}
}
