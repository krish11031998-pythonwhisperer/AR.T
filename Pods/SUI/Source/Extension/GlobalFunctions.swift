//
//  GlobalFunctions.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 08/09/2022.
//

import SwiftUI

public func asyncMainAnimation(animation: Animation = .linear, completion: @escaping () -> Void) {
	DispatchQueue.main.async {
		withAnimation(animation, completion)
	}
}

public func debug(_ val: Any) {
	print("(DEBUG) val : ", val)
}


