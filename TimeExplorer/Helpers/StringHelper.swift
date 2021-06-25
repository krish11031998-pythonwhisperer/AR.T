//
//  StringHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 09/12/2020.
//

import Foundation

extension String{
    
    func removeEndLine() -> String{
        let text = self
        return text.replacingOccurrences(of: "\n", with: "")
    }
    
    func stripSpaces() -> String{
        let text = self
        let finalText = text.components(separatedBy: " ").reduce("") { (res, x) -> String in
            return res == "" ? x : res + " " + x
        }
        return finalText
    }
    
    static func stringReducer(str:[String]) -> String{
        return str.reduce("") { (res, x) -> String in
            var res_str = ""
            if x == ""{
               return res
            }
            if res == ""{
                res_str = x
            }else{
                res_str = res + "\n\n" + x
            }
            return res_str
        }
    }
    
    func snakeCase() -> String{
        let text = self
//        let finalText = text.components(separatedBy: " ").reduce("") { (res, str) -> String in
//            return res == "" ? str.lowercased() : res + "_" + str.lowercased()
//        }
        let finalText = text.components(separatedBy: " ").reduce("") { $0 == "" ? $1.lowercased() : $0 + "_" + $1.lowercased()}
        return finalText
    }
}
