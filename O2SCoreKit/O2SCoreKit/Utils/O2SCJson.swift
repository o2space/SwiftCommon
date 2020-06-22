//
//  O2SCJson.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation

public class O2SCJson {
    
    /// Data数据转字符串
    /// - Parameter data: data数据
    public class func stringByData(_ data:Data) -> String? {
        var bytes = [UInt8](data)
        let pointer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(&bytes)
        var mData:Data = Data(bytes: pointer, count: data.count)
        mData.o2sc_writeInt8(0)
        
        var bytes2 = [UInt8](mData)
        let pointer2: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(&bytes2)
        let resStr = String(cString: pointer2)
        return resStr
    }
    
    /// 通过JSON字符串反序列化为对象
    /// - Parameter jsonString: JSON字符串
    public class func objectFromJSONString(_ jsonString:String) -> Any? {
        
        let jsonStr = O2SCRegex.stringByReplacingOccurrencesOfRegex("\\s", string: jsonString) { (captureCount, capturedStrings, capturedRanges, stop) -> String in
            if (capturedStrings[0] != " ") {
                return ""
            }
            return capturedStrings[0]
        }
        
        return try? JSONSerialization.jsonObject(with: jsonStr.data(using: String.Encoding.utf8)!, options: [])
    }
    
    /// 通过对象序列化为JSON字符串
    /// - Parameter jsonData: JSON数据
    public class func objectFromJSONData(_ jsonData:Data) -> Any? {
        if let res = O2SCJson.stringByData(jsonData) {
            return O2SCJson.objectFromJSONString(res)
        }
        return nil
    }
    
    public class func jsonStringFromObject(_ object:Any) -> String? {
        if let data = self.jsonDataFromObject(object) {
            return O2SCJson.stringByData(data)
        }
        return nil
    }
    
    public class func jsonDataFromObject(_ object:Any) -> Data? {
        return jsonDataFromObject(object) { (object) -> Any? in
            if let url = object as? URL {
                return url.absoluteString
            } else if let _ = object as? NSNull {
                
            } else if object == nil {
                
            } else if let obj = object as? AnyObject {
                return obj.description
            }
            
            return nil
        }
    }
    
    public class func jsonDataFromObject(_ object:Any,serializeUnsupportedClassesUsingBlock block:(_ object:Any?) -> Any?) -> Data? {
        
        do {
            var obj:Any? = object
            if !JSONSerialization.isValidJSONObject(obj!) {
                obj = self._convertObject(obj!, serializeUnsupportedClassesUsingBlock: block)
            }
            if let obj_t:Any = obj {
                if JSONSerialization.isValidJSONObject(obj_t) {
                    return try JSONSerialization.data(withJSONObject: obj_t, options: [])
                }
            }
        } catch {
            
        }
        
        return nil
    }
    
    
    /// JSON字符串 转 字典
    /// - Parameter jsonString: JSON字符串
    public class func  dictionaryFromJSONString(_ jsonString:String) -> Dictionary<String, Any>? {
        let jsonData:Data = jsonString.data(using: .utf8)!
           
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if let dict_t = dict {
            return dict_t as? Dictionary<String, Any>
        }
        return nil
    }
    
    /// JSON字符串 转 数组
    /// - Parameter jsonString: JSON字符串
    public class func arrayFromJSONString(_ jsonString:String) -> Array<Any>? {
        let jsonData:Data = jsonString.data(using: .utf8)!
         
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if let array_t = array as? Array<Any>{
            return array_t
        }
        return nil
    }
    
    /// 字典 转 JSON字符串
    /// - Parameter dict: 字典
    public static func JSONStringFromDictionary(_ dict:Dictionary<String, Any>) -> String {
        if !JSONSerialization.isValidJSONObject(dict) {
            print("无法解析出JSONString")
            return ""
        }
        
        let data: Data! = try? JSONSerialization.data(withJSONObject: dict, options: []) as Data
        let JSONString = String(data: data, encoding: String.Encoding.utf8)
        return JSONString! as String
    }
    
    /// 数组 转 JSON字符串
    /// - Parameter array: 数组
    public static func JSONStringFromArray(_ array:Array<Any>) -> String {
        if !JSONSerialization.isValidJSONObject(array) {
            print("无法解析出JSONString")
            return ""
        }
        
        let data: Data! = try? JSONSerialization.data(withJSONObject: array, options: []) as Data
        let JSONString = String(data: data, encoding: String.Encoding.utf8)
        return JSONString! as String
    }
    
    //MARK: - Private
    
    private class func _convertObject(_ object:Any,serializeUnsupportedClassesUsingBlock block:(_ object:Any?) -> Any?) -> Any? {
        var jsonObject:Any? = NSNull()
        if let obj_array = object as? Array<Any> {
            jsonObject = self._convertArrayObject(obj_array, serializeUnsupportedClassesUsingBlock: block)
        } else if let obj_dict = object as? Dictionary<String, Any> {
            jsonObject = self._convertDictObject(obj_dict, serializeUnsupportedClassesUsingBlock: block)
        } else if (object is String) || (object is Int) || (object is Bool) || (object is Float) || (object is Double) || (object is NSNull) {
            jsonObject = object
        } else {
            jsonObject = block(object)
            if (jsonObject is Dictionary<String, Any>) || (jsonObject is Array<Any>) {
                if !JSONSerialization.isValidJSONObject(jsonObject!) {
                    jsonObject = NSNull()
                }
            } else if !((object is String) || (object is Int) || (object is Bool) || (object is Float) || (object is Double) || (object is NSNull)) {
                jsonObject = NSNull()
            }
        }
        return jsonObject
    }
    
    private class func _convertDictObject(_ object:Dictionary<String,Any>,serializeUnsupportedClassesUsingBlock block:(_ object:Any?) -> Any?) -> Any? {
        var dict:Dictionary<String,Any> = Dictionary<String,Any>()
        for (key, value) in dict {
            if let jsonObj = self._convertObject(value, serializeUnsupportedClassesUsingBlock: block) {
                dict[key] = jsonObj
            }
        }
        return dict
    }
    
    private class func _convertArrayObject(_ object:Array<Any>,serializeUnsupportedClassesUsingBlock block:(_ object:Any?) -> Any?) -> Any? {
        var array:Array<Any> = Array<Any>()
        for item in object {
            if let jsonObj = self._convertObject(item, serializeUnsupportedClassesUsingBlock: block) {
                array.append(jsonObj)
            }
        }
        return array
    }
}
