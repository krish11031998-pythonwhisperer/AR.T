//
//  Loopable.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/8/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import Foundation

protocol Loopable{
    func allKeysValues(obj: Any?) throws -> [String:Any]
}

extension Loopable{
    func allKeysValues(obj: Any?) throws -> [String:Any]{
        var result:[String:Any] = [:]
        var mirror = Mirror(reflecting: obj ?? self)
        
        guard let style = mirror.displayStyle, style == .class || style == .struct else{
            print("This isn't a struct or a class")
            throw NSError()
        }
        for (prop,value) in mirror.children{
            if let key = prop{
                if let val = value as? [Any]{
                    result[key] = val.compactMap({ (el) -> Any? in
                        var res:[String:Any]? = nil
                        do {
                            res = try self.allKeysValues(obj: el)
                            
                        }catch{
                            print(error)
                        }
                        return res
                    })
                }
                else{
                    result[key] = value
                }
                
            }
        }
        
        return result
    }
    
}
