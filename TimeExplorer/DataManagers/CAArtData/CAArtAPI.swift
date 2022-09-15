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
	let currently_on_view: Bool
	let recently_acquired: Bool
	let may_show_artists: Bool
	let cia_alumni_artists: Bool
	let african_american_artists: Bool
	let female_artists: Bool
	
	
	init(q: String? = nil,
		 artist: String? = nil,
		 title: String? = nil,
		 department: Department? = nil,
		 type: Types? = nil,
		 has_image: Bool = true,
		 skip: Int? = nil,
		 limit: Int = 10,
		 currently_on_view: Bool = false,
		 recently_acquired: Bool = false,
		 may_show_artists: Bool = false,
		 cia_alumni_artists: Bool = false,
		 african_american_artists: Bool = false,
		 female_artists: Bool = false
	) {
		self.q = q
		self.artist = artist
		self.title = title
		self.department = department
		self.type = type
		self.has_image = has_image
		self.skip = skip
		self.limit = limit
		self.currently_on_view = currently_on_view
		self.recently_acquired = recently_acquired
		self.may_show_artists = may_show_artists
		self.cia_alumni_artists =  cia_alumni_artists
		self.african_american_artists = african_american_artists
		self.female_artists = female_artists
	}
	
	func queryItems() -> [URLQueryItem] {
		var items: [URLQueryItem] = [.init(name: "q", value: q),
		 .init(name: "artist", value: artist),
		 .init(name: "title", value: title),
		 .init(name: "department", value: department?.rawValue),
		 .init(name: "type", value: type?.rawValue),
		 .init(name: "has_image", value: has_image ? "1" : "0"),
		 .init(name: "skip", value: "\(skip ?? 0)"),
		 .init(name: "limit", value: "\(limit)"),
		].filter { $0.value != nil }
		
		if currently_on_view {
			items.append(.init(name: "currently_on_view", value: nil))
		}
		
		if recently_acquired {
			items.append(.init(name: "recently_acquired", value: nil))
		}
		
		if may_show_artists {
			items.append(.init(name: "may_show_artists", value: nil))
		}
		
		if cia_alumni_artists {
			items.append(.init(name: "cia_alumni_artists", value: nil))
		}
		
		if african_american_artists {
			items.append(.init(name: "african_american_artists", value: nil))
		}
		
		if female_artists {
			items.append(.init(name: "female_artists", value: nil))
		}
		
		return items
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
