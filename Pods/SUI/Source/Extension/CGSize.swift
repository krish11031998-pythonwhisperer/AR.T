//
//  CGS.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 06/09/2022.
//

import Foundation
import SwiftUI


//MARK: - Size Preference Key

public struct SizePreferenceKey: PreferenceKey {
	
	public static var defaultValue: CGSize = .zero
	
	public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}


//MARK: - CGSize Extension

public extension CGSize {
	init(squared: CGFloat) {
		self.init(width: squared, height: squared)
	}
	
	static var regularSize: Self { .init(squared: 50) }
}
