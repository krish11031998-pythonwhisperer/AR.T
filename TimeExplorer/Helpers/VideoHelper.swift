//
//  VideoHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 18/12/2020.
//

import Foundation
import SwiftUI
import AVFoundation

class VideoDownloader: ObservableObject{
    @Published var videoURL : URL? = nil
    @Published var videoThumbnail:UIImage? = nil
    
    func writeVideoToURL(_ data:Data?, urlTo to : URL) -> Bool{
        guard let data = data, let _ = try? data.write(to: to, options: .atomic) else {return false}
        return true
    }
    func downloadVideo(video_id v_id: String,urlString:String,completion: ((URL?) -> Void)? = nil){
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
                DispatchQueue.main.async {
                    self.videoURL = videoURL
                }
            }else{
                if self.writeVideoToURL(data, urlTo: videoURL){
                    DispatchQueue.main.async {
                        print("Succesfully wrote the data to the video URL")
                        self.videoURL = videoURL
                    }
                }else{
                    print("There was an error while writing the video content to the URL!")
                }
            }
        }.resume()
        
    }
    
}
