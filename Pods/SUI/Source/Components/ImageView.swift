//
//  ImageView.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 07/09/2022.
//

import SwiftUI

//MARK: - ImageLoadError

public enum ImageLoadError: String, Error {
	case invalidURL = "Invalid Url"
	case unknown = "Unknown Error"
	case imageDownlodFail = "(FAIL) Image was not downloaded"
}

public typealias UIImageResult = (Result<UIImage,ImageLoadError>) -> Void

//MARK: - UIImage Extension

public extension UIImage {
	
	static var cache: NSCache<NSString,UIImage> = { .init() }()
	
	static var callBacks: [String: [UIImageResult]] = [:]
	
	static func updateCallBacks(url: String, _ result: Result<UIImage, ImageLoadError>) {
		Self.callBacks[url]?.forEach { $0(result) }
		Self.callBacks[url] = nil
	}
	
	static var testImage: String { "https://weathereport.mypinata.cloud/ipfs/QmZJ56QmQpXQJamofJJYbR5T1gQTxVMhN5uHYfhvAmdFr8/85.png" }
	
	static func loadImage(url urlString: String, completion: @escaping UIImageResult) {
		
		if Self.callBacks[urlString] == nil {
			Self.callBacks[urlString] = [completion]
		} else {
			Self.callBacks[urlString]?.append(completion)
		}
		
		if let validImage = Self.cache.object(forKey: urlString as NSString) {
			Self.updateCallBacks(url: urlString, .success(validImage))
		} else {
			guard let url = URL(string: urlString) else {
				completion(.failure(.invalidURL))
				return
			}
		
			URLSession.shared.dataTask(with: url) { data, resp, err in
				guard let validData = data else {
					Self.updateCallBacks(url: urlString, .failure(.imageDownlodFail))
					return
				}
				
				guard let validImage =  UIImage(data: validData) else {
					Self.updateCallBacks(url: urlString, .failure(.unknown))
					return
				}
				
				Self.updateCallBacks(url: urlString, .success(validImage))
				
			}.resume()
		}
	}
}


//MARK: - ImageView - Component

public struct ImageView: View {
	@State var image: UIImage? = nil
	let url: String?
	
	public init(url: String? = nil, image: UIImage? = nil) {
		self.url = url
		self._image = .init(initialValue: image)
	}
	
	private func loadImage() {
		guard let validUrl = url else { return }
		UIImage.loadImage(url: validUrl) { result in
			switch result {
			case .success(let img):
				asyncMainAnimation(animation: .default) {
					self.image = img
				}
			case .failure(let err):
				print("(Error) Err :",err.localizedDescription)
			}
		}
		
	}
	
	public var body: some View {
		ZStack(alignment: .center) {
			Color.gray
				.opacity(image != nil ? 0 : 0.15)
			if let validImage = image {
				Image(uiImage: validImage)
					.resizable()
					.scaledToFill()
					.clipped()
			}
		}
		.onAppear(perform: loadImage)
	}
}

public extension View {
	
	func framed(size: CGSize, cornerRadius: CGFloat = 8, alignment: Alignment = .center) -> some View {
		self.frame(size: size, alignment: alignment)
			.clipContent(radius: cornerRadius)
	}
}

//MARK: - Preview
fileprivate struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
		ImageView(url: UIImage.testImage)
			.frame(size: .init(width: 200, height: 200))
			.clipShape(RoundedRectangle(cornerRadius: 20))
			.previewDevice("iPhone 12")
    }
}
