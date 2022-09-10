//
//  EndPoints.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import Foundation

public protocol EndPoint {
	
	var scheme: String { get }
	
	var baseURL: String { get }
	
	var method: String { get }
	
	var queryItem: [URLQueryItem] { get }
	
	var path: String { get }
	
	func execute<T:Codable>(completion: @escaping (Result<T, Error>) -> Void)
}
