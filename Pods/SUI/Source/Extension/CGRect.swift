//
//  CGRect.swift
//  SUI
//
//  Created by Krishna Venkatramani on 14/09/2022.
//

import Foundation
import SwiftUI

extension CGRect {
	
	var point: CGPoint {
		.init(x: origin.x + size.width.half, y: origin.y + size.height.half)
	}
	
	var midFrame: Self {
		.init(origin: point, size: size)
	}
}
