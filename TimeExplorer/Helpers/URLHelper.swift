//
//  URLHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 08/04/2021.
//

import Foundation

extension URL{
    func download(to: FileManager.SearchPathDirectory,filename:String, overwrite:Bool = false, handler: @escaping (URL?,Error?) -> Void) throws {
        let directory = try FileManager.default.url(for: to, in: .userDomainMask, appropriateFor: nil, create: true)
        let destination: URL = directory.appendingPathComponent(filename)
        
        if !overwrite && FileManager.default.fileExists(atPath: destination.path){
            handler(destination,nil)
            return
        }
        
        URLSession.shared.downloadTask(with: self) { (location, _, err) in
            guard let location = location else{
                    handler(nil,err)
                    return
            }
            
            do{
                if overwrite && FileManager.default.fileExists(atPath: location.path){
                    try FileManager.default.removeItem(at: location)
                }
                try FileManager.default.moveItem(at: location, to: destination)
                print("Downloaded the model to location: \(destination.absoluteString)")
                handler(destination,nil)
            }catch{
                handler(nil,error)
            }
        }.resume()
        
    }
}
