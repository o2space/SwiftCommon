//
//  O2SCBytes.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation

/// Byte数组读取数据
public class O2SCBytes {
    
    public class func readInt8FromBytes(_ array:[UInt8], offset:Int) -> Int8 {
        if array.count < offset + 1 {
            return 0
        }
        
        var value : Int8 = 0
        let data = NSData(bytes: array, length: array.count)
        data.getBytes(&value, range: NSMakeRange(offset, 1))
        value = Int8(bigEndian: value)
        return Int8(value)
    }
    
    public class func readInt16FromBytes(_ array:[UInt8], offset:Int) -> Int16 {
        if array.count < offset + 1 {
            return 0
        }
        
        var value : Int16 = 0
        let data = NSData(bytes: array, length: array.count)
        data.getBytes(&value, range: NSMakeRange(offset, 2))
        value = Int16(bigEndian: value)
        return Int16(value)
    }
    
    public class func readInt32FromBytes(_ array:[UInt8], offset:Int) -> Int32 {
        if array.count < offset + 1 {
            return 0
        }
        
        var value : Int32 = 0
        let data = NSData(bytes: array, length: array.count)
        data.getBytes(&value, range: NSMakeRange(offset, 4))
        value = Int32(bigEndian: value)
        return Int32(value)
    }
    
    public class func readInt64FromBytes(_ array:[UInt8], offset:Int) -> Int64 {
        if array.count < offset + 1 {
            return 0
        }
        
        var value : Int64 = 0
        let data = NSData(bytes: array, length: array.count)
        data.getBytes(&value, range: NSMakeRange(offset, 8))
        value = Int64(bigEndian: value)
        return Int64(value)
    }
    
    public class func readStringByData(_ data:Data, start:Int, lenght:Int) -> String {
        var endIndex = start
        if (start+lenght)>data.count{
            endIndex = data.count
        }else{
            endIndex = start+lenght
        }
        let data_t = data.subdata(in: start..<endIndex)
        let str = String(data: data_t, encoding: String.Encoding.utf8)
        return str ?? ""
    }
}

/// Int转Byte数组
public extension Int {
    
    func o2sc_to1Bytes() -> [UInt8] {
        let UInt = UInt8.init(Double.init(self))
        return [UInt8(truncatingIfNeeded: UInt)]
    }
    
    func o2sc_to2Bytes() -> [UInt8] {
        let UInt = UInt16.init(Double.init(self))
        return [UInt8(truncatingIfNeeded: UInt >> 8),
                UInt8(truncatingIfNeeded: UInt)]
    }
    
    func o2sc_to4Bytes() -> [UInt8] {
        let UInt = UInt32.init(Double.init(self))
        return [UInt8(truncatingIfNeeded: UInt >> 24),
                UInt8(truncatingIfNeeded: UInt >> 16),
                UInt8(truncatingIfNeeded: UInt >> 8),
                UInt8(truncatingIfNeeded: UInt)]
    }
    
    func o2sc_to8Bytes() -> [UInt8] {
        let UInt = UInt64.init(Double.init(self))
        return [UInt8(truncatingIfNeeded: UInt >> 56),
                UInt8(truncatingIfNeeded: UInt >> 48),
                UInt8(truncatingIfNeeded: UInt >> 40),
                UInt8(truncatingIfNeeded: UInt >> 32),
                UInt8(truncatingIfNeeded: UInt >> 24),
                UInt8(truncatingIfNeeded: UInt >> 16),
                UInt8(truncatingIfNeeded: UInt >> 8),
                UInt8(truncatingIfNeeded: UInt)]
    }
}


/// Data读写数据
public extension Data {
    
    mutating func o2sc_writeInt8(_ value:Int) {
        self.append(contentsOf: value.o2sc_to1Bytes())
    }
    func o2sc_readInt8(_ offset:Int) -> Int8 {
        let array:[UInt8] = [UInt8](self)
        return O2SCBytes.readInt8FromBytes(array, offset: offset)
    }
    
    mutating func o2sc_writeInt16(_ value:Int) {
        self.append(contentsOf: value.o2sc_to2Bytes())
    }
    func o2sc_readInt16(_ offset:Int) -> Int16 {
        let array:[UInt8] = [UInt8](self)
        return O2SCBytes.readInt16FromBytes(array, offset: offset)
    }
    
    mutating func o2sc_writeInt32(_ value:Int) {
        self.append(contentsOf: value.o2sc_to4Bytes())
    }
    func o2sc_readInt32(_ offset:Int) -> Int32 {
        let array:[UInt8] = [UInt8](self)
        return O2SCBytes.readInt32FromBytes(array, offset: offset)
    }
    
    mutating func o2sc_writeInt64(_ value:Int) {
        self.append(contentsOf: value.o2sc_to8Bytes())
    }
    func o2sc_readInt64(_ offset:Int) -> Int64 {
        let array:[UInt8] = [UInt8](self)
        return O2SCBytes.readInt64FromBytes(array, offset: offset)
    }
    
    mutating func o2sc_writeString(_ value:String) {
        let data:Data = value.data(using: String.Encoding.utf8)!
        self.append(data)
    }
    func o2sc_readString(_ start:Int, lenght:Int) -> String {
        return O2SCBytes.readStringByData(self, start: start, lenght: lenght)
    }
}
