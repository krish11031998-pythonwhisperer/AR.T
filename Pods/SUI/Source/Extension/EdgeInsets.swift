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
	
	init(by: CGFloat) {
		self.init(top: by, leading: by, bottom: by, trailing: by)
	}
	
	static var zero: EdgeInsets { .init(top: 0, leading: 0, bottom: 0, trailing: 0) }
}
