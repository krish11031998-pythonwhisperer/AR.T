//
//  EdgeInsets.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 08/09/2022.
//

import SwiftUI

public extension EdgeInsets {
	init(vertical: CGFloat = 0, horizontal: CGFloat = 0) {
		self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}
}
