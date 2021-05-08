//
//  VideoWriter.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/12/2020.
//

import Foundation
import AVFoundation
enum RecordState:String{
    case starting = "Start"
    case capturing = "Capturing"
    case ending = "Ending"
    case idle = "Idle"
}


class VideoWriter{
    private var buffer:CMSampleBuffer? = nil
    private var capturingState:RecordState
    private var assetWriter:AVAssetWriter? = nil
    private var assetWriterInput:AVAssetWriterInput? = nil
    private var adapter:AVAssetWriterInputPixelBufferAdaptor? = nil
    private var time:Double = 0
    private var filename:String = ""
    private var fileURL : URL? = nil
    var onRecordingEnded : ((URL) -> Void)? = nil
    
    init(_ capturingState:RecordState = .idle){
        self.capturingState = capturingState
        self.setupInputAdapter()
    }
    
    var captureMode:RecordState{
        get{
            return self.capturingState
        }
        set{
            self.capturingState = newValue
        }
    }
    
    var videoBuffer: CMSampleBuffer?{
        get{
            return self.buffer
        }
        set{
            self.buffer = newValue
        }
    }
    
    var timeFromBuffer:Double{
        get{
            guard let buffer = self.buffer else{return 0}
            return CMSampleBufferGetPresentationTimeStamp(buffer).seconds
        }
    }
    
    func setupInputAdapter(){
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
        input.mediaTimeScale = CMTimeScale(600)
        input.expectsMediaDataInRealTime = true
        input.transform = .init(rotationAngle: .pi/2)
        let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        self.assetWriterInput = input
        self.adapter = adapter
    }
    
    func setupVideoConverter(){
        
//        if !checkEverythingSetup(){
            do{
                guard let input = self.assetWriterInput, let adapter = self.adapter else {return}
                var _filename = UUID().uuidString
                let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mp4")
                self.fileURL = videoPath
                let writer = try AVAssetWriter(outputURL: videoPath, fileType: .mp4)
//                let input = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
//                input.mediaTimeScale = CMTimeScale(600)
//                input.expectsMediaDataInRealTime = true
//                input.transform = .init(rotationAngle: .pi/2)
//                let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
                if writer.canAdd(input){
                    writer.add(input)
                }
                writer.startWriting()
                writer.startSession(atSourceTime: .zero)
                self.assetWriter = writer
//                self.assetWriterInput = input
//                self.adapter = adapter
                self.time = self.timeFromBuffer
                self.capturingState = .capturing
                self.filename = _filename
                print("DEBUG MESSAGE : Starting to Record Video !")
            }catch{
                print("There was an error : \(error)")
            }
//        }
        
    }
    
    
    func captureVideo(){
        guard let input = self.assetWriterInput, let adapter = self.adapter, let buffer = self.buffer, let img = CMSampleBufferGetImageBuffer(buffer), self.capturingState == .capturing, input.isReadyForMoreMediaData == true  else {return}
        let time = CMTime(seconds: self.timeFromBuffer - self.time, preferredTimescale: .init(600))
        adapter.append(img, withPresentationTime: time)
        print("DEBUG MESSAGE : Recording Video !")
    }
    
    func endCapturingVideo(){
        guard let input = self.assetWriterInput, let writer = self.assetWriter, input.isReadyForMoreMediaData == true, writer.status != .failed ,let url = self.fileURL else {return}
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mp4")
        input.markAsFinished()
        writer.finishWriting {
            self.assetWriter = nil
            self.assetWriterInput = nil
            self.capturingState = .idle
            self.filename = ""
            self.fileURL = nil
        }
        if let completion = self.onRecordingEnded{
            completion(url)
        }
        print("DEBUG MESSAGE : End Recording Video !")
        
    }
    
}
