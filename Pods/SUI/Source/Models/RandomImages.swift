//
//  RandomImages.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import Foundation
import SwiftUI

//MARK: - RandomImage

public struct RandomImage: Codable {
	let id: String
	let author: String
	let width: Double
	let height: Double
	let url: String
	let download_url: String
	
	public init(id: String,
				author: String,
				width: Double,
				height: Double,
				url: String,
				download_url: String)
	{
		self.id = id
		self.author = author
		self.width = width
		self.height = height
		self.url = url
		self.download_url = download_url
	}
}

public typealias RandomImages = Array<RandomImage>

public extension RandomImage {
	
	func optimizedImage(size: CGSize) -> String {
		RandomImagesEndpoint.id(id: id, width: Int(size.width), height: Int(size.height)).url
	}
}

//MARK: - Random Images Endpoint

public enum RandomImagesEndpoint {
	case list(page: Int, limit: Int)
	case id(id: String, width: Int, height: Int)
}

extension RandomImagesEndpoint: EndPoint {
	public var scheme: String {
		"https"
	}
	
	
	public var baseURL: String {
		"picsum.photos"
	}
	
	public var method: String {
		switch self {
		case .list(_, _), .id(_, _, _):
			return "GET"
		}
		
	}
	
	public var queryItem: [URLQueryItem] {
		switch self {
		case .list(let page, let limit):
			return [
				.init(name: "page", value: "\(page)"),
				.init(name: "limit", value: "\(limit)")
			]
		default:
			return []
		}
	}
	
	public var path: String {
		switch self {
		case .list(_,  _):
			return "/v2/list"
		case .id(let id,let width, let height):
			return "/id/\(id)/\(width)/\(height)"
		}
		
	}
	
	public var url: String {
		var uC = URLComponents()
		uC.scheme = scheme
		uC.host = baseURL
		uC.path = path
		uC.queryItems = queryItem
		
		return uC.url?.absoluteString ?? ""
	}
	
	
	public func execute<T>(completion:@escaping (Result<T, Error>) -> Void) where T : Decodable, T : Encodable {
		NetworkRequest.shared.loadData(urlStr: url, completion: completion)
	}
}

//MARK: - RandomImageDownload

public  class RandomImagesDownloaders: ObservableObject {
	
	@Published public var images: RandomImages = []
	let endPoint: RandomImagesEndpoint
	
	public init(endPoint: RandomImagesEndpoint) {
		self.endPoint = endPoint
	}
	
	public func loadImage() {
		endPoint.execute { (result:Result<RandomImages,Error>) in
			switch result {
			case .success(let images):
				asyncMainAnimation(animation: .default) {
					self.images = images
				}
			case .failure(let err):
				print("(DEBUG) err: ",err.localizedDescription)
			}
		}
	}
}
