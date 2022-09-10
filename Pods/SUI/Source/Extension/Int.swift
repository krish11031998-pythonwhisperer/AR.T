//
//  Int.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 08/09/2022.
//

import Foundation
import UIKit

public extension Int {	
	var abs: Self { Swift.abs(self) }
	var cgFloat: CGFloat { CGFloat(self) }
	var double: Double { Double(self) }
	
	func isInRange(lower: Self, higher: Self) -> Bool {
		self >= lower && self <= higher
	}
}
