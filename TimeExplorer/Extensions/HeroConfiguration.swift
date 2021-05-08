//
//  HeroConfiguration.swift
//  HeroAnimations
//
//  Created by SwiftUI-Lab on 04-Jul-2020.
//  https://swiftui-lab.com/matchedGeometryEffect-part1
//

import SwiftUI

var sourceImagesSize = CGSize(width: conditionalWidth(600), height: 400)
//var totalWidth:CGFloat = UIScreen.main.bounds.width
//var totalHeight:CGFloat = UIScreen.main.bounds.height

func conditionalWidth(_ w:CGFloat) ->  CGFloat{
    return totalWidth > w ? w : totalWidth
}

public struct HeroConfiguration {
    
    private var _thumbnailScalingFactor: CGFloat = sourceImagesSize.width / sourceImagesSize.height

    /// Separation between rows in the grid
    var verticalSeparation: CGFloat = 30
    
    /// Separation between columns in the grid
    var horizontalSeparation: CGFloat = 30

    /// Thumbnail size
    var thumbnailSize: CGSize = CGSize(width: totalWidth * 0.9, height: 350)
    var thumbnailImageHeight:CGFloat{
        get{
            return self.thumbnailSize.height * 0.7
        }
    }
    
    var thumbnailCaptionHeight:CGFloat{
        get{
            return self.thumbnailSize.height * 0.3
        }
    }
    
    /// Thumbnail corner radius
    var thumbnailRadius: CGFloat = 15

    var modalImageHeight: CGFloat = 400
    var modalSize: CGSize = CGSize(width: totalWidth, height: totalHeight)
    var modalRadius: CGFloat = 15
    
    /// Use dark mode
    var darkMode: Bool = true
    
    /// Aspect ratio of provided images
    var aspectRatio: CGFloat = sourceImagesSize.width / sourceImagesSize.height
    
    /// Zoomed factor of thumbnail images. It is kept valid by checking with lowestFactor and
    /// highestFactor. These are determine by the thumbnail size.
    var thumbnailScalingFactor: CGFloat {
        get { min(max(_thumbnailScalingFactor, lowestFactor), highestFactor) }
        set { _thumbnailScalingFactor = min(max(newValue, lowestFactor), highestFactor) }
    }
    
    /// A default configuration
    public static let `default` = HeroConfiguration()
    
    /// The default configuration for portrait layouts
    public static let defaultPortrait = HeroConfiguration(
        verticalSeparation: 20,
        horizontalSeparation: 20,
        thumbnailSize: CGSize(width: conditionalWidth(700), height: 200),
        thumbnailScalingFactor: 1.5,
        thumbnailRadius: 12,
        modalImageHeight: 400,
        modalSize: CGSize(width: conditionalWidth(600), height: 800),
        modalRadius: 20,
        darkMode: true,
        aspectRatio: sourceImagesSize.width / sourceImagesSize.height)
    
    /// The default configuration for landscape layouts
    public static let defaultLandscape = HeroConfiguration(
        verticalSeparation: 0,
        horizontalSeparation: 0,
        thumbnailSize: CGSize(width: conditionalWidth(280), height: 280),
        thumbnailScalingFactor: 1.5,
        thumbnailRadius: 0,
        modalImageHeight: 400,
        modalSize: CGSize(width: conditionalWidth(600), height: 700),
        modalRadius: 20,
        darkMode: true,
        aspectRatio: sourceImagesSize.width / sourceImagesSize.height)
    
    /// Thumbnail's aspect ratio (read-only)
    var thumbnailAspectRatio: CGFloat {
        return (thumbnailSize.width / thumbnailSize.height)
    }
    
    /// Lowest scaling factor possible for the current thumbnail size
    var lowestFactor: CGFloat {
        return max(aspectRatio / thumbnailAspectRatio, 1)
    }
    
    /// Highest scaling factor possible for the current thumbnail size
    var highestFactor: CGFloat {
        return lowestFactor * 6;
    }
    
    init() {
        self.thumbnailScalingFactor = _thumbnailScalingFactor // make sure it is in bounds
    }
    
    init(verticalSeparation: CGFloat, horizontalSeparation: CGFloat, thumbnailSize: CGSize, thumbnailScalingFactor: CGFloat,  thumbnailRadius: CGFloat, modalImageHeight: CGFloat, modalSize: CGSize, modalRadius: CGFloat, darkMode: Bool, aspectRatio: CGFloat) {
        self.verticalSeparation = verticalSeparation
        self.horizontalSeparation = horizontalSeparation
        self.thumbnailSize = thumbnailSize
        self.thumbnailScalingFactor = thumbnailScalingFactor
        self.thumbnailRadius = thumbnailRadius
        self.modalSize = modalSize
        self.modalRadius = modalRadius
        self.darkMode = darkMode
        self.aspectRatio = aspectRatio
    }
}

