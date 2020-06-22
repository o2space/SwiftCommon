//
//  O2SCKeychain.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation

internal let O2SCSecureDataNameKey = ".O2SCSecureData"

public class O2SCKeychainService : NSObject {
    
    /// 缓存数据集合
    var keyChainDataCollection:Dictionary<String, Any>?
    
    public static let sharedInstance:O2SCKeychainService = {
        let instance = O2SCKeychainService()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    public func setSecureData(_ data:Any?, forKey key:String) -> Bool {
        var successCache:Bool = false
        self.o2sc_withSynchoronized(obj: self) {
            if data != nil{
                guard let _ = data as? NSCoding else {
                    debugPrint("cache data dose not conforms NSCoding protocol.")
                    return
                }
            }
            var hasInTrans = false
            var container:Dictionary<String, Any>? = self.keyChainDataCollection
            if container != nil {
                hasInTrans = true
            } else {
                container = self._secureDataContainer()
                if  container == nil {
                    container = Dictionary<String, Any>()
                }
            }
            
            if data == nil {
                container!.removeValue(forKey: key)
            } else {
                container?[key] = data
            }
            if !hasInTrans {
                //保存数据
                successCache = self._saveSecureDataContainer(container!)
            } else {
                self.keyChainDataCollection = container
            }
        }
        return successCache
    }
    
    public func secureDataForKey(_ key:String) -> Any? {
        var model:Any? = nil
        self.o2sc_withSynchoronized(obj: self) {
            var container:Dictionary<String, Any>? = self.keyChainDataCollection
            if container == nil {
                container = self._secureDataContainer()
                if  container == nil {
                    container = Dictionary<String, Any>()
                }
            }
            model = container?[key]
        }
        return model
    }
    
    //MARK: Private
    
    private func _secureDataContainer() -> Dictionary<String, Any>? {
        var ret:Dictionary<String, Any>? = nil
        if let data = O2SCKeychain.keyChainReadData(identifier: self._keychainQuery()) as? Data {
            if #available(iOS 11.0, *) {
                if let cacheData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary<String, Any> {
                    ret = cacheData
                }
            } else {
                ret = NSKeyedUnarchiver.unarchiveObject(with: data) as? Dictionary<String, Any>
            }
        }
        return ret
    }
    
    private func _saveSecureDataContainer(_ container:Dictionary<String, Any>) -> Bool {
        if #available(iOS 11.0, *) {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: container, requiringSecureCoding: true) {
                return O2SCKeychain.keyChainSaveData(data: data, withIdentifier: self._keychainQuery())
            }
        } else {
            let data = NSKeyedArchiver.archivedData(withRootObject: container)
            return O2SCKeychain.keyChainSaveData(data: data, withIdentifier: self._keychainQuery())
        }
        return false
    }
    
    private func _keychainQuery() -> String {
        //生成服务名称
        let serviceName:String = (Bundle.main.bundleIdentifier ?? "") + O2SCSecureDataNameKey
        return serviceName
    }
}

class O2SCKeychain: NSObject {
    // TODO: 创建查询条件
    class func createQuaryMutableDictionary(identifier:String)->NSMutableDictionary{
        // 创建一个条件字典
        let keychainQuaryMutableDictionary = NSMutableDictionary.init(capacity: 0)
        // 设置条件存储的类型
        keychainQuaryMutableDictionary.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        // 设置存储数据的标记
        keychainQuaryMutableDictionary.setValue(identifier, forKey: kSecAttrService as String)
        keychainQuaryMutableDictionary.setValue(identifier, forKey: kSecAttrAccount as String)
        // 设置数据访问属性
        keychainQuaryMutableDictionary.setValue(kSecAttrAccessibleAfterFirstUnlock, forKey: kSecAttrAccessible as String)
        // 返回创建条件字典
        return keychainQuaryMutableDictionary
    }
    
    // TODO: 存储数据
    class func keyChainSaveData(data:Any ,withIdentifier identifier:String)->Bool {
        // 获取存储数据的条件
        let keyChainSaveMutableDictionary = self.createQuaryMutableDictionary(identifier: identifier)
        // 删除旧的存储数据
        SecItemDelete(keyChainSaveMutableDictionary)
        // 设置数据
        keyChainSaveMutableDictionary.setValue(NSKeyedArchiver.archivedData(withRootObject: data), forKey: kSecValueData as String)
        // 进行存储数据
        let saveState = SecItemAdd(keyChainSaveMutableDictionary, nil)
        if saveState == noErr  {
            return true
        }
        return false
    }

    // TODO: 更新数据
    class func keyChainUpdata(data:Any ,withIdentifier identifier:String)->Bool {
        // 获取更新的条件
        let keyChainUpdataMutableDictionary = self.createQuaryMutableDictionary(identifier: identifier)
        // 创建数据存储字典
        let updataMutableDictionary = NSMutableDictionary.init(capacity: 0)
        // 设置数据
        updataMutableDictionary.setValue(NSKeyedArchiver.archivedData(withRootObject: data), forKey: kSecValueData as String)
        // 更新数据
        let updataStatus = SecItemUpdate(keyChainUpdataMutableDictionary, updataMutableDictionary)
        if updataStatus == noErr {
            return true
        }
        return false
    }
    
    // TODO: 获取数据
    class func keyChainReadData(identifier:String)-> Any {
        var idObject:Any?
        // 获取查询条件
        let keyChainReadmutableDictionary = self.createQuaryMutableDictionary(identifier: identifier)
        // 提供查询数据的两个必要参数
        keyChainReadmutableDictionary.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        keyChainReadmutableDictionary.setValue(kSecMatchLimitOne, forKey: kSecMatchLimit as String)
        // 创建获取数据的引用
        var queryResult: AnyObject?
        // 通过查询是否存储在数据
        let readStatus = withUnsafeMutablePointer(to: &queryResult) { SecItemCopyMatching(keyChainReadmutableDictionary, UnsafeMutablePointer($0))}
        if readStatus == errSecSuccess {
            if let data = queryResult as! NSData? {
                idObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as Any
            }
        }
        return idObject as Any
    }
    
    // TODO: 删除数据
    class func keyChianDelete(identifier:String)->Void{
        // 获取删除的条件
        let keyChainDeleteMutableDictionary = self.createQuaryMutableDictionary(identifier: identifier)
        // 删除数据
        SecItemDelete(keyChainDeleteMutableDictionary)
    }
}
