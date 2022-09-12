//
//  Misc.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 12/09/2022.
//

import Foundation

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
