//
//  Array.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import Foundation
import SwiftUI

public enum CodableColors: String, Codable, CaseIterable {
	case indigo
	case blue
	case red
	case green
	case black
	case brown
}

public extension CodableColors {
	var color: Color {
		switch self {
		case .indigo:
			return .indigo
		case .blue:
			return .blue
		case .red:
			return .red
		case .green:
			return .green
		case .black:
			return .black
		case .brown:
			return .brown
		}
	}
}

public struct ColorCodable: Codable {
	public let data: CodableColors
	
	public init(data: CodableColors) {
		self.data = data
	}
}
