//
//  AVPlayerHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 17/12/2020.
//

import Foundation
import AVFoundation

extension AVAsset{
    
    
    static func convertVideoToMP4(toConvertURL to: URL, completion: @escaping (URL?) -> Void){
        var asset = AVURLAsset(url: to)
        let startDate = Date()
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough), let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let n = to.absoluteString.components(separatedBy: "/").last, let name = n.components(separatedBy: ".").first else{
            completion(nil)
            return
        }
        
        let filePath = documentPath.appendingPathComponent("\(name).mp4")
        if FileManager.default.fileExists(atPath: filePath.path){
            do{
                try FileManager.default.removeItem(at: filePath)
            }catch{
                print("There was an error ! :\(error)")
                completion(nil)
            }
        }
        
        exportSession.outputURL = filePath
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRange(start: start, duration: asset.duration)
        exportSession.timeRange = range
        
        exportSession.exportAsynchronously {
            switch exportSession.status{
                case .failed:
                    print("MP4 Conversion FAILED!")
                    completion(nil)
                    break
                case .cancelled:
                    print("MP4 Conversion CANCELLED!")
                    completion(nil)
                    break
                case .completed:
                    
                    if let outputURL = exportSession.outputURL{
                        var end = Date()
                        var conversion_time = end.timeIntervalSince(startDate)
                        print("MP4 Conversion COMPLETED : \(outputURL)!")
                        completion(outputURL)
                    }else{
                        print("Its completed but outputURL == nil")
                    }
                    break
                default:
                    break
            }
        }
        
    }
    
    static func downloadVideo(video_id v_id: String,urlString:String,completion: ((URL?) -> Void)? = nil){
        guard let url = URL(string: urlString) else {
            if completion != nil{
                completion!(nil)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data, let baseURL = baseURL else {
                if let err = err?.localizedDescription{
                    print("There was an error while downloading the video : \(err)")
                }
                return
            }
            
            var videoURL = baseURL.appendingPathComponent("\(v_id).mp4")
            if FileManager.default.fileExists(atPath: videoURL.path){
                print("File already exists !")
                if let completion = completion{
                    completion(videoURL)
                }
            }else{
                DispatchQueue.main.async {
                    if let _ = try? data.write(to: videoURL, options: .atomic){
                        print("Succesfully wrote the data to the video URL")
                        completion?(videoURL)
                    }else{
                        print("There was an error while writing the video content to the URL!")
                        completion?(nil)
                    }
                }
            }
        }.resume()
        
    }
}


extension AVPlayer{
    func seek(state:VideoStates) -> VideoStates{
        let player = self
        let seconds = player.currentTime().seconds
        let curr_time = Float64(seconds)
        let diff = Float64(state == .seekBack ? -10 : 10)
        player.seek(to: CMTimeMakeWithSeconds(curr_time + diff, preferredTimescale: 1),toleranceBefore: .zero,toleranceAfter: .zero)
        player.play()
        return .play
    }
}

