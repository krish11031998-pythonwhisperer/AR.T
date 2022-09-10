//
//  NetworkRequest.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import Foundation
import SwiftUI

public class NetworkRequest {
	static var cache:NSCache<NSString,NSData> = .init()
	
	static var shared: NetworkRequest = .init()
	
	func loadData<T:Codable>(urlStr: String, completion: @escaping (Result<T,Error>) -> Void) {
		if let validData = Self.cache.object(forKey: urlStr as NSString) as? Data {
			completion(self.parseData(data: validData))
		} else {
			
			guard let url = URL(string: urlStr) else { return }
			
			let session = URLSession(configuration: .default)
			let dataTask = session.dataTask(with: url) { data, resp, err in
				guard let validData = data else {
					if err != nil {
						completion(.failure(err!))
					}
					return 
				}
				
				Self.cache.setObject(validData as NSData, forKey: urlStr as NSString)
				
				completion(self.parseData(data: validData))
			}
			
			dataTask.resume()
			
		}
	}
	
	func parseData<T:Codable>(data: Data) -> Result<T,Error> {
		let decoder = JSONDecoder()
		do {
			let data = try decoder.decode(T.self, from: data)
			return .success(data)
		} catch {
			return .failure(error)
		}
	}
}
