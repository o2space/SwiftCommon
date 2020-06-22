//
//  O2SCRegex.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation

public class O2SCRegex {
    
    public class func stringByReplacingOccurrencesOfRegex(_ regex:String, string:String, usingBlock block:(_ captureCount:Int, _ capturedStrings:[String], _ capturedRanges:[NSRange], _ stop:UnsafeMutablePointer<ObjCBool>) -> String) -> String {
        // 创建正则表达式对象
        guard let regExp = try? NSRegularExpression(pattern: regex, options: []) else {
            return ""
        }
        var replaceStr:String = string
        var offset = 0
        regExp.enumerateMatches(in: string, options: [.reportCompletion], range: NSRange(location: 0, length: string.count)) { (result, flags, stop) in
            if result != nil {
                var resultRange:NSRange = result!.range
                if resultRange.location != NSNotFound && resultRange.length > 0 {
                    resultRange.location += offset
                    var str:[String] = Array<String>()
                    var range:[NSRange] = Array<NSRange>()
                                        
                    for i in 0..<result!.numberOfRanges {
                        let range_t = result!.range(at: i)
                        range.append(range_t)
                        str.append((string as NSString).substring(with: range_t))
                    }
                                        
                    let replTemplateStr:String = block(result!.numberOfRanges, str, range, stop)
                                        
                    let range_t = Range(resultRange, in: replaceStr)
                    replaceStr = replaceStr.replacingCharacters(in: range_t!, with: replTemplateStr)
                    offset += replTemplateStr.count - resultRange.length
                }
            } else {
                stop.pointee = true
            }
        }
        return replaceStr
    }
}
