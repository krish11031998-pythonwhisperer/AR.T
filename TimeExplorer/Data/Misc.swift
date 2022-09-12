//
//  Misc.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 12/09/2022.
//

import Foundation
import SwiftUI

struct ExploreData{
	var img:String?
	var data:Any?
}

struct PostID:Identifiable{
	var id:Int
	var post:Any
	var date:Date?
}

enum ClipperShape{
	case allcorners
	case cutLeft
	case cutRight
}

extension CGSize{
	static func + (lhs:CGSize,rhs:CGSize) -> CGSize{
		return .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
	}
}

extension CGRect{
	func centralize() -> CGSize{
		let card = self
		let midX = card.midX
		let midY = card.midY
		let diff_w = (totalWidth * 0.5) - midX
		let diff_h = (totalHeight * 0.5) - midY
		let res:CGSize = .init(width: diff_w, height: diff_h)
		return res
	}
	
}

enum ViewFrameType{
	case like
	case play
	case pause
	case forward
	case backward
	case idle
//    case videoControl
}
