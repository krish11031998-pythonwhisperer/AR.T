//
//  RoundedButton.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 07/09/2022.
//

import Foundation
import SwiftUI

//MARK: - Definations
public typealias Callback = () -> Void

//MARK: -  RoundedButtonModel

public struct RoundedButtonModel {
	
	public struct RoundedButtonImageModel {
		let img: UIImage?
		let imgUrl: String?
		let size: CGSize
		let cornerRadius: CGFloat
		
		public init(img: UIImage? = nil,
			 imgURL: String? = nil,
			 size: CGSize = .init(squared: 50),
			 cornerRadius: CGFloat = 8)
		{
			self.img = img
			self.imgUrl = imgURL
			self.size = size
			self.cornerRadius = cornerRadius
		}
	}
	
	public struct RoundedButtonBlob {
		let backgroundColor: Color
		let padding: CGFloat
		let cornerRadius: CGFloat
		
		public init(background: Color = .white, padding: CGFloat = 10, cornerRadius: CGFloat = 8) {
			self.backgroundColor = background
			self.padding = padding
			self.cornerRadius = cornerRadius
		}
	}
	
	let leadingImg: RoundedButtonImageModel?
	let trailingImg: RoundedButtonImageModel?
	let topLeadingText: RenderableText?
	let bottomLeadingText: RenderableText?
	let topTrailingText: RenderableText?
	let bottomTrailingText: RenderableText?
	let blob: RoundedButtonBlob?
	var handler: Callback?

	
	public init(
		leadingImg: RoundedButtonImageModel? = nil,
		trailingImg: RoundedButtonImageModel? = nil,
		topLeadingText: RenderableText? = nil,
		bottomLeadingText: RenderableText? = nil,
		topTrailingText: RenderableText? = nil,
		bottomTrailingText: RenderableText? = nil,
		blob: RoundedButtonBlob? = nil,
		handler: Callback? = nil)
	{
		self.leadingImg = leadingImg
		self.trailingImg = trailingImg
		self.topLeadingText = topLeadingText
		self.bottomLeadingText = bottomLeadingText
		self.topTrailingText = topTrailingText
		self.bottomTrailingText = bottomTrailingText
		self.blob = blob
		self.handler = handler
	}
}

public extension RoundedButtonModel {
	static var testModelLeading: RoundedButtonModel {
		let leadingImg = RoundedButtonModel.RoundedButtonImageModel(imgURL: UIImage.testImage, cornerRadius: 16)
		return .init(leadingImg: leadingImg,
					 topLeadingText: "Title".styled(font: .systemFont(ofSize: 15, weight: .semibold), color: .black),
					 bottomLeadingText: "SubTitle".styled(font: .systemFont(ofSize: 13, weight: .medium), color: .black),
					 topTrailingText: "Caption".styled(font: .systemFont(ofSize: 14, weight: .medium), color: .black),
					 bottomTrailingText: "SubCaption".styled(font: .systemFont(ofSize: 12, weight: .regular), color: .black))
		
	}

	static var testModelTrailing: RoundedButtonModel {
		let trailingImg = RoundedButtonModel.RoundedButtonImageModel(imgURL: UIImage.testImage, cornerRadius: 16)
		return .init(trailingImg: trailingImg,
					 topLeadingText: "Title".styled(font: .systemFont(ofSize: 15, weight: .semibold), color: .black),
					 bottomLeadingText: "SubTitle".styled(font: .systemFont(ofSize: 13, weight: .medium), color: .black),
					 topTrailingText: "Caption".styled(font: .systemFont(ofSize: 14, weight: .medium), color: .black),
					 bottomTrailingText: "SubCaption".styled(font: .systemFont(ofSize: 12, weight: .regular), color: .black))
		
	}

	static var testModel: RoundedButtonModel {
		return .init(topLeadingText: "Title".styled(font: .systemFont(ofSize: 15, weight: .semibold), color: .black),
					 bottomLeadingText: "SubTitle".styled(font: .systemFont(ofSize: 13, weight: .medium), color: .black),
					 topTrailingText: "Caption".styled(font: .systemFont(ofSize: 14, weight: .medium), color: .black),
					 bottomTrailingText: "SubCaption".styled(font: .systemFont(ofSize: 12, weight: .regular), color: .black))
		
	}

	static var testModelWithBlob: RoundedButtonModel {
		let leadingImg = RoundedButtonModel.RoundedButtonImageModel(imgURL: UIImage.testImage, cornerRadius: 16)
		let trailingImg = RoundedButtonModel.RoundedButtonImageModel(imgURL: UIImage.testImage, cornerRadius: 16)
		return .init(leadingImg: leadingImg,
					 trailingImg: trailingImg,
					 topLeadingText: "Title".styled(font: .systemFont(ofSize: 15, weight: .semibold), color: .black),
					 bottomLeadingText: "SubTitle".styled(font: .systemFont(ofSize: 13, weight: .medium), color: .black),
					 topTrailingText: "Caption".styled(font: .systemFont(ofSize: 14, weight: .medium), color: .black),
					 bottomTrailingText: "SubCaption".styled(font: .systemFont(ofSize: 12, weight: .regular), color: .black),
					 blob: RoundedButtonModel.RoundedButtonBlob(background: .black.opacity(0.05), padding: 20, cornerRadius: 20))
		
	}
}

//MARK: - RoundedButton

public struct RoundedButton: View {

	let model: RoundedButtonModel
	let action: Callback?
	
	public init(model: RoundedButtonModel, action: Callback? = nil) {
		self.model = model
		self.action = action
	}
	
	private var leadingStack: some View {
		VStack(alignment: .leading) {
			if let validTopLeadingText = model.topLeadingText {
				validTopLeadingText.text
			}
			Spacer()
			if let validBottomLeadingText = model.bottomLeadingText {
				validBottomLeadingText.text
			}
		}
	}
	
	private var trailingStack: some View {
		VStack(alignment: .trailing) {
			if let validTopTrailingText = model.topTrailingText {
				validTopTrailingText.text
			}
			Spacer()
			if let validBottomTrailingText = model.bottomTrailingText {
				validBottomTrailingText.text
			}
		}
	}
	
	
	private var mainButton: some View {
		HStack(alignment: .center, spacing: 10) {
			if model.leadingImg != nil {
				ImageView(url: model.leadingImg?.imgUrl, image: model.leadingImg?.img)
					.frame(size: model.leadingImg?.size ?? .regularSize)
					.clipContent(radius: model.leadingImg?.cornerRadius ?? 0)
			}
			leadingStack
			Spacer()
			trailingStack
			if model.trailingImg != nil {
				ImageView(url: model.trailingImg?.imgUrl, image: model.trailingImg?.img)
					.frame(size: model.trailingImg?.size ?? .regularSize)
					.clipContent(radius: model.trailingImg?.cornerRadius ?? 0)
			}
		}
		
	}
	
	public var body: some View {
		if let blob = model.blob {
			mainButton
				.blobify(background: blob.backgroundColor, padding: blob.padding, cornerRadius: blob.cornerRadius)
				.buttonify {
					action?()
				}
				.fixedSize(horizontal: false, vertical: true)
		} else {
			mainButton
				.contentShape(Rectangle())
				.buttonify {
					action?()
				}
				.fixedSize(horizontal: false, vertical: true)
		}
	}
}


