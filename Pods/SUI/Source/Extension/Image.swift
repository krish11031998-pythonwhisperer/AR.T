//
//  Image.swift
//  SUI
//
//  Created by Krishna Venkatramani on 14/09/2022.
//

import Foundation
import SwiftUI

extension Image {
	
	func scaleToFit() -> some View {
		self.resizable().scaledToFit()
	}
	
	func scaleToFill() -> some View {
		self.resizable().scaledToFill()
	}
}
