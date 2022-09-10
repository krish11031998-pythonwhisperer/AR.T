//
//  CGFloat.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 05/09/2022.
//

import Foundation
import SwiftUI

//MARK: - CGFloat Extension

public extension CGFloat {
	static var totalWidth: CGFloat { UIScreen.main.bounds.width }
	static var totalHeight: CGFloat { UIScreen.main.bounds.height }
	
	var half: Self { self * 0.5 }
	
	func boundedTo(lower: Self = 0, higher: Self = 1) -> Self { self < lower ? lower : self > higher ? higher : self }
	
	static var safeAreaInsets: UIEdgeInsets {
		
		let keyWindow = UIApplication.shared.connectedScenes
		
			.filter({$0.activationState == .foregroundActive})
		
			.map({$0 as? UIWindowScene})
		
			.compactMap({$0})
		
			.first?.windows
		
			.filter({$0.isKeyWindow}).first
		
		
		
		return (keyWindow?.safeAreaInsets) ?? .zero
	}
	
	static var safeAreaVerticalInsets: CGFloat {
		Self.safeAreaInsets.top + Self.safeAreaInsets.bottom
	}
}

//MARK: - ClosedRange

public extension ClosedRange where Bound == CGFloat {
	
	func normalize(_ val: CGFloat) -> CGFloat {
		let max = upperBound
		let min = lowerBound
		
		return (val - min)/(max - min)
	}
	
	func isInRange(_ val: Self.Bound) -> Bool {
		return val >= lowerBound && val <= upperBound
	}
}

//MARK: - Array

public extension Array where Element == CGFloat {
	
	var average: Self.Element {
		reduce(0, +)/CGFloat(count)
	}
}
