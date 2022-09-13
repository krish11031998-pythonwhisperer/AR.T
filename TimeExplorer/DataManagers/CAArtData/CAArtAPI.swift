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
	let department: String?
	let type: String?
	let has_image: Bool
	let skip: Int?
	let limit: Int
	
	init(q: String? = nil,
		 artist: String? = nil,
		 title: String? = nil,
		 department: String? = nil,
		 type: String? = nil,
		 has_image: Bool = true,
		 skip: Int? = nil,
		 limit: Int = 100
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
		guard let items = try? allKeysValues(obj: self) else { return [] }
		return items.compactMap { el in
			if let strVal = el.value as? String {
				return .init(name: el.key, value: strVal)
			} else if let intVal = el.value as? Int {
				return .init(name: el.key, value: "\(intVal)")
			} else if el.key == "has_image" , let cond = el.value as? Bool {
				return .init(name: el.key, value: "\(cond ? 1 : 0)")
			}
			return nil
		}
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
//
//class ArtService: ObservableObject {
//
//	let endpoint: ArtAPIEndpoint
//	
//	init(endpoint: ArtAPIEndpoint) {
//		self.endpoint = endpoint
//	}
//	
//
//	func fetchArt() {
//		endpoint.execute { [weak self] (result: Result<[CAData],Error>) in
//			switch result {
//			case .success(let data):
//				DispatchQueue.main.async {
//					self?.art = data
//				}
//			case .failure(let err):
//				print("(DEBUG) err : ",err.localizedDescription)
//			}
//		}
//	}
//
//}
