//
//  O2SCBaseError.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/22.
//  Copyright © 2020 O2Space. All rights reserved.
//

import Foundation

public protocol O2SCBaseErrorProtocol: LocalizedError {
    
    var errorDomain: String? {get}
    
    var errorCode: Int? {get}
    
    var errorUserInfo:[String : Any]? {get}
}

public class O2SCBaseError: O2SCBaseErrorProtocol {
    public var errorDomain: String?
    public var errorCode: Int?
    public var errorUserInfo: [String : Any]?
    
    var desc = ""
    
    public init(_ desc: String) {
        self.desc = desc;
    }
    
    public init(_ domain:String?, code:Int, userInfo:[String : Any]?) {
        self.errorDomain = domain
        self.errorCode = code
        self.errorUserInfo = userInfo
    }
    
    public var errorDescription: String? {
        if desc.count != 0 {
            return desc
        } else {
            var str = ""
            str = str.appendingFormat("domain:%@, code:%@, userInfo:%@", [self.errorDomain ?? "", self.errorCode ?? "", self.errorUserInfo?.description ?? "" as Any])
            return str
        }
    }
    
}
