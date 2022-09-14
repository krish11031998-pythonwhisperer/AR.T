//
//  CAArtAPI.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/09/2022.
//

import Foundation
import SUI

//MARK: - Search API
struct SearchParam: Loopable {
	let q: String?
	let artist: String?
	let title: String?
	let department: Department?
	let type: Types?
	let has_image: Bool
	let skip: Int?
	let limit: Int
	
	init(q: String? = nil,
		 artist: String? = nil,
		 title: String? = nil,
		 department: Department? = nil,
		 type: Types? = nil,
		 has_image: Bool = true,
		 skip: Int? = nil,
		 limit: Int = 10
	) {
		self.q = q
		self.artist = artist
		self.title = title
		self.department = department
		self.type = type
		self.has_image = has_image
		self.skip = skip
		self.limit = limit
	}
	
	func queryItems() -> [URLQueryItem] {
		return [.init(name: "q", value: q),
		 .init(name: "artist", value: artist),
		 .init(name: "title", value: title),
		 .init(name: "department", value: department?.rawValue),
		 .init(name: "type", value: type?.rawValue),
		 .init(name: "has_image", value: has_image ? "1" : "0"),
		 .init(name: "skip", value: "\(skip ?? 0)"),
		 .init(name: "limit", value: "\(limit)"),
		].filter { $0.value != nil }
	}
}

enum ArtAPIEndpoint {
	case search(SearchParam)
	case artWork(String)
}

extension ArtAPIEndpoint: EndPoint {
	var scheme: String {
		switch self {
		default:
			return "https"
		}
	}
	
	var baseURL: String {
		"openaccess-api.clevelandart.org"
	}
	
	var method: String {
		switch self {
		case .search(_):
			return "GET"
		default:
			return "GET"
		}
	}
	
	var queryItem: [URLQueryItem] {
		switch self {
		case .search(let searchParam):
			return searchParam.queryItems()
		default:
			return []
		}
	}
	
	var path: String {
		switch self {
		case .search(_):
			return "/api/artworks"
		case .artWork(let id):
			return "/api/artworks/\(id)"
		}
	}
	
	var url: String {
		var uC = URLComponents()
		uC.scheme = scheme
		uC.host = baseURL
		uC.path = path
		uC.queryItems = queryItem
		
		return uC.url?.absoluteString ?? ""
	}
	
	func execute<T>(completion: @escaping (Result<T, Error>) -> Void) where T : Decodable, T : Encodable {
		print("(NETWORK) ====== \(url) ======")
		NetworkRequest.shared.loadData(urlStr: url, completion: completion)
	}
}
