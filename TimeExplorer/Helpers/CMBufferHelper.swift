//
//  CMBufferHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/12/2020.
//

import Foundation
import AVFoundation
import UIKit

extension CMSampleBuffer{
    func getImageFromBuffer() -> UIImage?{
        var buffer = self
        var result:UIImage? = nil
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imgRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imgRect){
                result = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return result
    }
}
