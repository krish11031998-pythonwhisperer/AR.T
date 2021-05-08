//
//  SpeechModel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 02/04/2021.
//

import SwiftUI
import AVKit


class SpeechModel:NSObject,ObservableObject,AVSpeechSynthesizerDelegate{
    @Published var isSpeaking:Bool = false
    @Published var currentWord:String = ""
    var pausedWord:String = ""
    private var synthesizer = AVSpeechSynthesizer()
    
    override init(){
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(speechText:String){
        var utterance = AVSpeechUtterance(string: speechText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        utterance.preUtteranceDelay = 1
        utterance.postUtteranceDelay = 1
        self.synthesizer.speak(utterance)
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func pause(){
        self.synthesizer.pauseSpeaking(at: .immediate)
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func continueSpeaking(){
        self.synthesizer.continueSpeaking()
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        DispatchQueue.main.async {
//            self.isSpeaking = true
//        }
//    }
//
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
//        DispatchQueue.main.async {
//            self.isSpeaking = false
//        }
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
//        DispatchQueue.main.async {
//            self.isSpeaking = true
//        }
//    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableStr = NSMutableString(string: utterance.speechString)
        let word = mutableStr.substring(with:characterRange)
        DispatchQueue.main.async {
            self.currentWord = word
        }
        
    }
}


