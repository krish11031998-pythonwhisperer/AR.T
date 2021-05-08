//
//  InstagramAPI.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/16/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import Foundation

var IDCache:NSCache<NSString,NSData> = .init()

class TaskManager {
    static let shared = TaskManager()
    
    let session = URLSession(configuration: .default)
    
    typealias completionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var tasks = [URL: [completionHandler]]()
    
    func dataTask(with url: URL, completion: @escaping completionHandler) {
        if tasks.keys.contains(url) {
            tasks[url]?.append(completion)
        } else {
            tasks[url] = [completion]
            let _ = session.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                DispatchQueue.main.async {
                    
                    print("Finished network task")
                    
                    guard let completionHandlers = self?.tasks[url] else { return }
                    for handler in completionHandlers {
                        
                        print("Executing completion block")
                        
                        handler(data, response, error)
                    }
                }
            }).resume()
        }
    }
}

class InstagramAPI:ObservableObject{
    
    var mainURL:String = "https://www.instagram.com/explore/tags/"
    var queryString:String = "?__a=1"
    var tag:String = ""
    @Published var result:FinalInstagramData = .init()
    @Published var taggedResults:[String:(recent:[IPDNode],top:[IPDNode])] = [:]
    var latestDate:Date = .init()
    init(tag:String){
        self.tag = tag
    }
    
    
    var finalURL:String{
        get{
            return "\(self.mainURL)\(tag)/\(queryString)"
        }
    }
    
    func dataParsing(safeData:Data,type:String = "single",handler:@escaping (_ data:FinalInstagramData? )->Void){
        if let safeParsedData = self.parseData(data: safeData){
            DispatchQueue.main.async {
                var formatR = FinalInstagramData(mainHeader: .init(name: safeParsedData.name, profile_pic_url: safeParsedData.profile_pic_url), recent: safeParsedData.edge_hashtag_to_media, top: safeParsedData.edge_hashtag_to_top_posts)
                if type == "single"{
                    if self.result.recent != nil && self.result.top != nil{
                        if let _recent = self.result.recent?.edges,let recent = formatR.recent?.edges{
                            self.result.recent?.edges = _recent + recent
                        }
                        if let _top = self.result.top?.edges, let top = formatR.recent?.edges{
                            self.result.top?.edges = _top + top
                        }
                    }else{
                        self.result = formatR
                    }
                    handler(nil)
                }else if type == "multiple"{
                    handler(formatR)
                }
            }
        }else{
            handler(nil)
        }
    }
    
    func getData(handler: @escaping () -> Void){
        var finalURL = self.finalURL
        
        if let safeData = IDCache.object(forKey: finalURL as NSString) as? Data{
            self.dataParsing(safeData: safeData){ data in
                handler()
            }
        }else{
            if let urlRequest = URL(string: finalURL){
                
                URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
                    guard let safeData = data else {
                        if let safeErr = err{
                            print(safeErr.localizedDescription)
                        }
                        return
                    }
                    IDCache.setObject(safeData as NSData, forKey: finalURL as NSString)
                    self.dataParsing(safeData: safeData) { data in
                        handler()
                    }
                }.resume()
                
                
            }else {
                handler()
            }
        }
    }
    
    
    func getMultipleTags(tags:[String]){
        self.latestDate = Date()
        tags.forEach { (tag) in
            var urlStr = "\(self.mainURL)\(tag)/\(queryString)"
            print("urlStr: \(urlStr)")
            if let safeData = IDCache.object(forKey: urlStr as NSString) as? Data{
                self.dataParsing(safeData: safeData,type: "multiple"){ data in
                    if let SPD = data{
                        var res = (top: SPD.top?.edges ?? [],recent: SPD.recent?.edges ?? [])
                        self.taggedResults["\(tag)"] = res
                    }
                }
            }else{
                if let urlRequest = URL(string: urlStr){
                    TaskManager.shared.dataTask(with: urlRequest) { (data, resp, err) in
                        guard let safeData = data else {
                            if let safeErr = err{
                                print(safeErr.localizedDescription)
                            }
                            return
                        }
                        IDCache.setObject(safeData as NSData, forKey: urlStr as NSString)
                        self.dataParsing(safeData: safeData,type: "multiple") { data in
                            if let SPD = data{
                                var res = (top: SPD.top?.edges ?? [],recent: SPD.recent?.edges ?? [])
                                self.taggedResults["\(tag)"] = res
                            }else{
                                if self.taggedResults.isEmpty{
                                    self.taggedResults = ["test":(top:Array(IPDexamples[0..<10]),recent:IPDexamples)]
                                    print("taggedResults is being updated to test!")
                                }
                            }
                        }
                        
                    }
                }
                
            }
        }
        
    }
    
    static func parsedTaggedResult(data:[String:(recent:[IPDNode],top:[IPDNode])]) -> [PostID]{
        
        var result:[PostID] = []
        var nodes:[IPDNode] = []
        
        nodes = Array(data.values).reduce([], { (res, x) -> [IPDNode] in
            return res + x.recent
        })
        
        var count = 0
        result = nodes.compactMap { (node) -> PostID? in
            var mappedRes:PostID? = nil
            if let safePost = node.node{
                mappedRes = PostID(id: count, post: safePost)
                count += 1
            }
            return mappedRes
        }
        return result
    }
    
    func parseData(data:Data) -> InstagramResult? {
        var decoder = JSONDecoder()
        var res:InstagramResult? = nil
        do {
            var result = try decoder.decode(IDR.self, from: data)
            res = result.graphql.hashtag
        }catch{
            print("There was an error (parseData)! \(error)")
        }
        return res
    }
    
}
