//
//  CAAPI.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 27/06/2021.
//

import SwiftUI
import Foundation
import Combine

class ArtAPI:ObservableObject{
	
    @Published var artDatas:[CAData] = []
    var url = "https://openaccess-api.clevelandart.org/api/artworks/"
	
    var cancellable = Set<AnyCancellable>()
    static let shared = ArtAPI()
    
    init(limit:Int? = nil ,department:String?=nil,type:String?=nil,skip:Int? = nil){
        guard let limit = limit, let dpt = department, let type = type, let skip = skip else {return}
        self.getBatchArt(limit: limit, department: dpt, type: type, skip: skip)
    }
    
    func checkOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data{
        let (data,response) = output
        if let resp = response as? HTTPURLResponse, resp.statusCode > 200 && resp.statusCode < 300 {
            print("statusCode : \(resp.statusCode)")
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    
    func parseBatchData(data:Data){
        let decoder = JSONDecoder()
        var res:CAResultBatch? = nil
        do {
            res = try decoder.decode(CAResultBatch.self, from: data)
        }catch{
            print("There was an error while trying to decoding CAResult : \(error.localizedDescription)")
        }
        
        if let safeRes = res,let safeData = safeRes.data{
            DispatchQueue.main.async {
                self.artDatas = safeData
            }
        }
    }
    
    func parseData(data: Data,type: String){
        switch type{
            case "batch":
                self.parseBatchData(data: data)
            default:
                print("Can't parse Data , invalid option!")
        }
    }
    
    
    func getBatchArt(limit:Int = 50,department: String?=nil,type: String?=nil,skip: Int? = nil){
        url += "?"
        
        
        if let dpt = department{
            url += "department=\(dpt)&"
        }
        
        if let t = type{
            url += "type=\(t)&"
        }
        
        if let s = skip{
            url += "skip=\(s)&"
        }
        
        url += "has_image=1&limit=\(limit)"
        
        guard let url = URL(string: url) else {return}
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .tryMap(self.checkOutput(output:))
            .sink { _ in
            } receiveValue: {[weak self] data in
                self?.parseData(data: data,type: "batch")
            }
            .store(in: &cancellable)

    }
    
    
    func getArt(id: String = "1922.1133"){
        url += "\(id)?indent=1"
        guard let url = URL(string: url) else {return}
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.global(qos: .background))
            .tryMap(self.checkOutput(output:))
            .sink { _ in
            } receiveValue: {[weak self] data in
                self?.parseData(data: data, type: "single")
            }
            .store(in: &cancellable)
	}
}




