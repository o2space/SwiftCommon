//
//  O2SCCrypt.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation
import CommonCrypto

public class O2SCCrypt {
    
    /// url字符串 编码
    /// - Parameters:
    ///   - string: url字符串
    ///   - encoding: 编码类型
    public class func urlEncodeString(_ string:String, forEncoding encoding:String.Encoding) -> String? {
        let KUrlCodingReservedCharacters = "!*'();:|@&=+$,/?%#[]{}"
        return string.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: KUrlCodingReservedCharacters).inverted)
    }
    
    /// url字符串 解码
    /// - Parameters:
    ///   - string: url字符串
    ///   - encoding: 编码类型
    public class func urlDecodeString(_ string:String, forEncoding encoding:String.Encoding) -> String? {
        return string.removingPercentEncoding
    }
    
    /// 将Data转换成16进制字符串(如："0f98abd4")
    /// - Parameter data: 原始数据
    public class func hexStringByData(_ data:Data) -> String {
        let bytes = [UInt8](data)
        return self.hexStringByBytes(bytes).replacingOccurrences(of: " ", with: "")
    }
    
    /// 将16进制字符串转换成Data
    /// - Parameter hexString: 16进制字符串 如："0f98abd4"
    public class func dataByHexString(_ hexString:String) -> Data? {
        if hexString.count % 2 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        var sum = 0
        // 整形的 utf8 编码范围
        let intRange = 48...57
        // 小写 a~f 的 utf8 的编码范围
        let lowercaseRange = 97...102
        // 大写 A~F 的 utf8 的编码范围
        let uppercasedRange = 65...70
        for (index, c) in hexString.utf8CString.enumerated() {
            var intC = Int(c.byteSwapped)
            if intC == 0 {
                break
            } else if intRange.contains(intC) {
                intC -= 48
            } else if lowercaseRange.contains(intC) {
                intC -= 87
            } else if uppercasedRange.contains(intC) {
                intC -= 55
            } else {
                return nil
            }
            sum = sum * 16 + intC
            // 每两个十六进制字母代表8位，即一个字节
            if index % 2 != 0 {
                bytes.append(UInt8(sum))
                sum = 0
            }
        }
        return Data(bytes)
    }
    
    /// 将[UInt8]转换成16进制字符串
    /// - Parameter bytes: 原始数据
    public class func hexStringByBytes(_ bytes:[UInt8]) -> String {
        var hexStr = ""
        for index in 0 ..< bytes.count {
            var Str = bytes[index].description
            if Str.count == 1 {
                Str = "0 "+Str
            }else {
                let low = Int(Str)!%16
                let hight = Int(Str)!/16
                Str = _hexIntToStr(HexInt: hight) + _hexIntToStr(HexInt: low)
            }
            hexStr += Str
        }
        return hexStr
    }
    
    /// 使用BASE64编码数据
    /// - Parameter data: 原始数据
    public class func stringByBase64EncodeData(_ data:Data) -> String {
        return data.base64EncodedString(options: Data.Base64EncodingOptions.init(arrayLiteral: NSData.Base64EncodingOptions.lineLength64Characters))
    }
    
    /// 使用BASE64进行解码
    /// - Parameter string: 原始字符串
    public class func dataByBase64DecodeString(_ string:String) -> Data? {
        return Data(base64Encoded: string, options: Data.Base64DecodingOptions.init(arrayLiteral: NSData.Base64DecodingOptions.ignoreUnknownCharacters))
    }
    
    /// 使用BASE64进行解码
    /// - Parameter string: 原始字符串
    public class func stringByBase64DecodeString(_ string:String) -> String? {
        if let data = self.dataByBase64DecodeString(string) {
            return String(data: data, encoding: String.Encoding.utf8) ?? nil
        }
        return nil
    }
    
    public class func stringByBase64EncodeData(_ data:Data, mask:Data) -> String {
        let maskBytes = [UInt8](mask)
        var bytes = [UInt8](data)
        
        for i in 0..<bytes.count {
            let l = i % maskBytes.count;
            bytes[i] = bytes[i] ^ maskBytes[l]
        }
        let lastData = Data(bytes: bytes, count: bytes.count)
        return self.stringByBase64EncodeData(lastData)
    }
    
    public class func stringByBase64DecodeString(_ string:String, mask:Data) -> String? {
        
        if let data = self.dataByBase64DecodeString(string) {
            let maskBytes = [UInt8](mask)
            var bytes = [UInt8](data)
                   
            for i in 0..<bytes.count {
                let l = i % maskBytes.count;
                bytes[i] = bytes[i] ^ maskBytes[l]
            }
            let lastData = Data(bytes: bytes, count: bytes.count)
            return String(data: lastData, encoding: String.Encoding.utf8) ?? nil
        }
       
        return nil
    }
    
    
    /// SHA-MD5
    /// - Parameter plainString: 签名字符串
    /// - Return 16进制字符串
    public class func md5(plainString: String) -> String {
        return sha(plainString: plainString, algorithm: O2SCSHAAlgorithm.MD5)
    }
    
    /// SHA
    /// - Parameters:
    ///   - plainString: 签名字符串
    ///   - algorithm: SHA类型
    /// - Return 16进制字符串
    public class func sha(plainString: String, algorithm:O2SCSHAAlgorithm) -> String {
        
        let str = plainString.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(plainString.lengthOfBytes(using: String.Encoding.utf8))
        let digestLength = algorithm.digestLength()
        let closure = algorithm.progressClosure()
        let bytes = closure(str!, strLen)
        
        var hashString: String = ""
        for i in 0..<digestLength {
            hashString += String(format: "%02x", bytes[i])
        }
        return hashString
    }
    
    /// hmac
    /// - Parameters:
    ///   - plainString: 原始字符串
    ///   - algorithm: SHA类型
    ///   - key: key
    /// - Return: Base64编码值
    public class func hmac(plainString: String, algorithm:O2SCHMACAlgorithm, key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = plainString.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        CCHmac(algorithm.toCCHmacAlgorithm(), cKey!, strlen(cKey!), cData!, strlen(cData!), &result)
        let hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        let hmacBase64 = hmacData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        return String(hmacBase64)
    }
    
    /// 对数据进行AES128加密
    /// - Parameters:
    ///   - plainData: 原始数据/明文
    ///   - encryptionKey: 密钥
    ///   - encoding: 字符串编码
    public class func aes128Encrypt(plainData: Data, encryptionKey: String, encoding: String.Encoding) throws -> Data {
        return try aes128Encrypt(plainData: plainData, encryptionKey: encryptionKey.data(using: encoding)!, options: CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode))
    }
    
    /// 对数据进行AES128加密
    /// - Parameters:
    ///   - plainData: 原始数据/明文
    ///   - encryptionKey: 密钥
    ///   - options: 模式
    public class func aes128Encrypt(plainData: Data, encryptionKey: Data, options: CCOptions) throws -> Data {
        let encrypted = try _dataByAES128(data: plainData, withOperation: CCOperation(kCCEncrypt), forKey: encryptionKey, andIV: nil, andOptions: options)
        guard encrypted.status == UInt32(kCCSuccess) else {
            throw O2SCBaseError("Encryption failed with CryptoStatus:\(encrypted.status).")
        }
        return encrypted.data
    }
    
    /// 对数据进行AES128解密
    /// - Parameters:
    ///   - cipherData: 密文
    ///   - decryptionKey: 密钥
    ///   - encoding: 字符串编码
    public class func aes128Decrypt(cipherData: Data, decryptionKey: String, encoding: String.Encoding) throws -> Data {
        return try aes128Decrypt(cipherData: cipherData, decryptionKey: decryptionKey.data(using: encoding)!, options: CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode))
    }
    
    /// 对数据进行AES128解密
    /// - Parameters:
    ///   - cipherData: 密文
    ///   - decryptionKey: 密钥
    ///   - options: 模式
    public class func aes128Decrypt(cipherData: Data, decryptionKey: Data, options: CCOptions) throws -> Data {
        let decrypted = try _dataByAES128(data: cipherData, withOperation: CCOperation(kCCDecrypt), forKey: decryptionKey, andIV: nil, andOptions: options)
        guard decrypted.status == UInt32(kCCSuccess) else {
            throw O2SCBaseError("Decryption failed with CryptoStatus: \(decrypted.status).")
        }

        return decrypted.data
    }
    
    //MARK: - Private Function
    
    private class func _hexIntToStr(HexInt:Int) -> String {
        var Str = ""
        if HexInt>9 {
            switch HexInt{
            case 10:
                Str = "A"
                break
            case 11:
                Str = "B"
                break
            case 12:
                Str = "C"
                break
            case 13:
                Str = "D"
                break
            case 14:
                Str = "E"
                break
            case 15:
                Str = "F"
                break
            default:
                Str = "0"
            }
        }else {
            Str = String(HexInt)
        }
        
        return Str
    }
    
    private class func _dataByAES128(data: Data, withOperation operation: CCOperation, forKey key:Data, andIV iv:Data?, andOptions options: CCOptions) throws -> (data: Data, status: UInt32)  {
        let keyLength = key.count
        guard keyLength * 8 == 128 else {
            throw O2SCBaseError("Invalid key, Length not equal to 128")
        }
        let dataLength = data.count
        let initializationVector: Data
        if let ivData = iv {
            initializationVector = ivData
        } else {
            initializationVector = Data()
        }
                
        guard dataLength > 0, keyLength > 0 else {
            throw O2SCBaseError("Invalid Parameter")
        }
                
        let cryptLength  = size_t(dataLength + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)
                
        var numBytesCrypted: size_t = 0
                
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                initializationVector.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(operation,
                                CCAlgorithm(kCCAlgorithmAES128),
                                options,
                                keyBytes.baseAddress!, keyLength,
                                ivBytes.baseAddress!,
                                dataBytes.baseAddress!, dataLength,
                                cryptBytes.baseAddress!, cryptLength,
                                &numBytesCrypted)
                    }
                }
            }
        }

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesCrypted..<cryptLength)
        }

        return (cryptData, UInt32(cryptStatus))
    }
    
}

public typealias O2SCDigestAlgorithmClosure = (_ data: UnsafeRawPointer, _ dataLength: UInt32) -> [UInt8]
public enum O2SCSHAAlgorithm {
    case MD2, MD4, MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func progressClosure() -> O2SCDigestAlgorithmClosure {
        var closure: O2SCDigestAlgorithmClosure?
        switch self {
        case .MD2:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_MD2($0, $1, &hash)
                
                return hash
            }
        case .MD4:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_MD4($0, $1, &hash)
                
                return hash
            }
        case .MD5:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_MD5($0, $1, &hash)
                
                return hash
            }
        case .SHA1:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA1($0, $1, &hash)
                
                return hash
            }
        case .SHA224:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA224($0, $1, &hash)
                
                return hash
            }
        case .SHA256:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA256($0, $1, &hash)
                
                return hash
            }
        case .SHA384:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA384($0, $1, &hash)
                
                return hash
            }
        case .SHA512:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA512($0, $1, &hash)
                
                return hash
            }
        }
        return closure!
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD2:
            result = CC_MD2_DIGEST_LENGTH
        case .MD4:
        result = CC_MD4_DIGEST_LENGTH
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
public enum O2SCHMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
