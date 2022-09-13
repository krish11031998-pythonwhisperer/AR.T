//
//  LabelButton.swift
//  SUI
//
//  Created by Krishna Venkatramani on 12/09/2022.
//

import SwiftUI

//MARK: - LabelButtonConfig
public enum ImageData {
	case url(String)
	case img(String)
}

public extension ImageData {
	var value: String? {
		switch self {
		case .url(let url):
			return url
		case .img(let img):
			return img
		}
	}
}
public struct LabelButtonConfig {
	public enum ImageDirection: String {
		case top
		case left
		case right
		case bottom
	}
	
	public enum Alignment: String {
		case vertical
		case horizontal
	}
	
	public enum ImageStyle {
		case clipped
		case rounded(CGFloat)
	}
	
	public struct LabelConfig {
		let spacing: CGFloat
		let alignment: SwiftUI.HorizontalAlignment
		
		public init(spacing: CGFloat, alignment: SwiftUI.HorizontalAlignment) {
			self.spacing = spacing
			self.alignment = alignment
		}
	}
	
	let imgDirection: ImageDirection
	let orientation: LabelButtonConfig.Alignment
	let alignment: SwiftUI.Alignment
	let spacing: CGFloat
	let imageSize: CGSize
	let imageStyle: ImageStyle
	let labelConfig: LabelConfig
	
	public init(imgDirection: ImageDirection = .left,
		 orientation: LabelButtonConfig.Alignment = .horizontal,
		 alignment: SwiftUI.Alignment = .leading,
		 labelConfig: LabelConfig = .init(spacing: 10, alignment: .leading),
		 spacing: CGFloat = 8,
		 imageSize: CGSize,
		 imageStyle: ImageStyle
	) {
		self.imgDirection = imgDirection
		self.orientation = orientation
		self.alignment = alignment
		self.labelConfig = labelConfig
		self.spacing = spacing
		self.imageSize = imageSize
		self.imageStyle = imageStyle
	}
}

public extension LabelButtonConfig.ImageStyle {
	var radius: CGFloat {
		switch self {
		case .rounded(let rad):
			return rad
		case .clipped:
			return 0
		}
	}
}

extension LabelButtonConfig: Equatable {
	
	public static func == (lhs: LabelButtonConfig, rhs: LabelButtonConfig) -> Bool {
		lhs.alignment == rhs.alignment &&
		lhs.imgDirection == rhs.imgDirection &&
		lhs.orientation == rhs.orientation
	}
}

//MARK: - LabelButton

public struct LabelButton: View {
	
	let config: LabelButtonConfig
	let image: ImageData
	let title: RenderableText
	let subTitle: RenderableText?
	let handler: (() -> Void)?
	
	public init(config: LabelButtonConfig,
		 image: ImageData,
		 title: RenderableText,
		 subTitle: RenderableText?,
		 handler: (() -> Void)? = nil) {
	
		self.config = config
		self.image = image
		self.title = title
		self.subTitle = subTitle
		self.handler = handler
	}
	
	
	@ViewBuilder private var imgView: some View {
		switch image {
		case .url(let url):
			ImageView(url: url)
		case .img(let imgName):
			ImageView(image: .init(named: imgName))
		}
	}
	
	private var verticalButton: some View {
		VStack(alignment: config.alignment.horizontal, spacing: config.spacing) {
			if config.imgDirection == .top {
				imgView
					.framed(size: config.imageSize, cornerRadius: config.imageStyle.radius, alignment: .center)
			}
			HeaderSubHeadView(title: title, subTitle: subTitle, spacing: config.labelConfig.spacing, alignment: config.labelConfig.alignment)
			if config.imgDirection == .bottom {
				imgView
					.framed(size: config.imageSize, cornerRadius: config.imageStyle.radius, alignment: .center)
			}
		}
	}

	private var horizontalButton: some View {
		HStack(alignment: config.alignment.vertical, spacing: config.spacing) {
			if config.imgDirection == .left {
				imgView
					.framed(size: config.imageSize, cornerRadius: config.imageStyle.radius, alignment: .center)
			}
			HeaderSubHeadView(title: title, subTitle: subTitle, spacing: config.labelConfig.spacing, alignment: config.labelConfig.alignment)
			if config.imgDirection == .right {
				imgView
					.framed(size: config.imageSize, cornerRadius: config.imageStyle.radius, alignment: .center)
			}
		}
	}
	
	@ViewBuilder private var buttonBody: some View {
		if config.orientation == .vertical {
			verticalButton
		} else {
			horizontalButton
		}
	}
	
    public var body: some View {
		buttonBody
			.buttonify {
				handler?()
			}
    }
}


struct LabelButton_Previews: PreviewProvider {
	
	static var config: LabelButtonConfig {
		.init(imgDirection: .left,
			  orientation: .horizontal,
			  alignment: .trailing,
			  spacing: 8,
			  imageSize: .init(squared: 100),
			  imageStyle: .rounded(50))
	}
	
    static var previews: some View {
		LabelButton(config: Self.config,
					image: .url(UIImage.testImage),
					title: "Hello".styled(font: .systemFont(ofSize: 20, weight: .bold), color: .black),
					subTitle: "World".styled(font: .systemFont(ofSize: 16, weight: .semibold), color: .gray))
		.padding()
		.fillWidth(alignment: .leading)
    }
}
