//
//  O2SCDevice.swift
//  O2SCoreKit
//
//  Created by wkx on 2020/6/19.
//  Copyright © 2020 O2Space. All rights reserved.
//

import UIKit
import CoreTelephony
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork

public enum O2SCNetworkType : Int {
    case None           = 0 // 无网络
    case Wifi           = 1 // wifi
    case Cellular       = 2 // 蜂窝网络
    case Cellular2G     = 3 // 2G网络
    case Cellular3G     = 4 // 3G网络
    case Cellular4G     = 5 // 4G网络
    case Cellular5G     = 6 // 5G网络
}

public enum O2SCIPVersion : Int {
    case ipv4   = 0
    case ipv6   = 1
}


// duid、cputype、wifiLevel未实现

public class O2SCDevice {
    private static let networkInfo:CTTelephonyNetworkInfo = {
        return CTTelephonyNetworkInfo()
    }()
    
    private static let base64Mask:Data = {
        let bytes:[UInt8] = [0x01,0x02,0x03,0x04,0x50,0x10,0x20,0x30,0x40,0x50]
        let data = Data(bytes: bytes, count: bytes.count)
        return data
    }()
    
    private static let jailbreak_apps = [ "/Applications/Cydia.app","/Applications/limera1n.app","/Applications/greenpois0n.app","/Applications/blackra1n.app","/Applications/blacksn0w.app","/Applications/redsn0w.app",]
    
    //MARK: - Public Func
    
    
    /// 获取网卡物理地址
    public static func macAddress() -> String {
        return "02:00:00:00:00:00"
    }
    
    /// 获取设备型号
    public static func deviceModel() -> String {
        return _getSysInfoByName("hw.machine")
    }
    
    
    /// 获取当前网络类型
    public static func currentNetworkType() -> O2SCNetworkType {
        var networkType:O2SCNetworkType = .None
        var reachability:O2SCReachability!
        do {
            reachability = try O2SCReachability()
        } catch {
            return networkType
        }
        
//        debugPrint(reachability.connection.description)
        
//        // 网络变化
//        // 网络可用或切换网络类型时执行
//        reachability.whenReachable = {reachability in
//            if reachability.connection == .wifi {
//
//            } else {
//
//            }
//        }
//        // 网络不可用时执行
//        reachability.whenUnreachable = {reachability in
//
//        }
//
//        do {
//            // 开始监听
//            try reachability.startNotifier()
//        } catch {
//
//        }
        
        
        switch reachability.connection {
        case .unavailable:
            networkType = .None
        case .wifi:
            networkType = .Wifi
        case .cellular:
            networkType = .Cellular
        default:
            networkType = .None
        }
        
        if networkType == .Cellular && versionCompare("7.0").rawValue > ComparisonResult.orderedAscending.rawValue {
            if let status:String = networkInfo.currentRadioAccessTechnology {
                if status == "CTRadioAccessTechnologyGPRS" || status == "CTRadioAccessTechnologyEdge" || status == "CTRadioAccessTechnologyCDMA1x" {
                    networkType = .Cellular2G
                } else if status == "CTRadioAccessTechnologyCDMAEVDORev0" || status == "CTRadioAccessTechnologyCDMAEVDORevA" || status == "CTRadioAccessTechnologyCDMAEVDORevB" || status == "CTRadioAccessTechnologyWCDMA" || status == "CTRadioAccessTechnologyHSDPA" || status == "CTRadioAccessTechnologyHSUPA" || status == "CTRadioAccessTechnologyeHRPD" {
                    networkType = .Cellular3G
                } else if status == "CTRadioAccessTechnologyLTE" {
                    networkType = .Cellular4G
                }
            }
        }
        
        return networkType
    }
    
    
    /// 获取手机运营商代码
    public static func carrier() -> String {
        let netinfo = self.networkInfo
        if let carrier:CTCarrier = netinfo.subscriberCellularProvider {
            return String(format: "%@%@", carrier.mobileCountryCode ?? "",carrier.mobileNetworkCode ?? "")
        }
        return ""
    }
    
    
    /// 获取手机运营商名称
    public static func carrierName() -> String {
        let netinfo = self.networkInfo
        if let carrier:CTCarrier = netinfo.subscriberCellularProvider {
            return carrier.carrierName ?? ""
        }
        return ""
    }
    
    /// 获取手机运营商国家码
    public static func mobileCountryCode() -> String {
        let netinfo = self.networkInfo
        if let carrier:CTCarrier = netinfo.subscriberCellularProvider {
            return carrier.mobileCountryCode ?? ""
        }
        return ""
    }
    
    /// 获取手机运营商网络编号
    public static func mobileNetworkCode() -> String {
        let netinfo = self.networkInfo
        if let carrier:CTCarrier = netinfo.subscriberCellularProvider {
            return carrier.mobileNetworkCode ?? ""
        }
        return ""
    }
    
    
    /// 与当前系统版本比较
    /// - Parameter other: 需要对比的版本
    /// 返回.orderedAscending为低于指定版本；orderedSame为指定版本相同；orderedDescending为高于指定版本
    public static func versionCompare(_ other:String) -> ComparisonResult {
        let oneComponents:Array = UIDevice.current.systemVersion.split(separator: "a")
        let twoComponents:Array = other.split(separator: "a")
        
        var oneVerComponents:Array<Substring> = Array<Substring>()
        var twoVerComponents:Array<Substring> = Array<Substring>()
        
        if oneComponents.count > 0 {
            oneVerComponents = oneComponents[0].split(separator: ".")
        }
        
        if twoComponents.count > 0 {
            twoVerComponents = twoComponents[0].split(separator: ".")
        }
        
        var mainDiff:ComparisonResult = .orderedSame
        
        for (index,item) in oneVerComponents.enumerated() {
            let oneVer:Int! = Int(item)
            if twoVerComponents.count > index {
                let twoVer:Int! = Int(twoVerComponents[index])
                if oneVer > twoVer {
                    mainDiff = .orderedDescending
                    break
                } else if oneVer < twoVer {
                    mainDiff = .orderedAscending
                    break
                }
            } else {
                mainDiff = .orderedDescending
                break
            }
        }
        
        if mainDiff != .orderedSame {
            return mainDiff
        }
        
        if oneVerComponents.count < twoVerComponents.count {
            return .orderedAscending
        }
        
        if oneComponents.count < twoComponents.count {
            return .orderedDescending
        } else if oneComponents.count > twoComponents.count {
            return .orderedAscending
        } else if oneComponents.count == 1 {
            return .orderedSame
        }
        
        let oneAlpha:NSNumber = NSNumber(value: Int(oneComponents[1])!)
        let twoAlpha:NSNumber = NSNumber(value: Int(twoComponents[1])!)
        
        return oneAlpha.compare(twoAlpha)
    }
    
    
    /// 判断是否越狱，true:越狱，false:尚未越狱
    public static func hasJailBroken() -> Bool {
        for item in jailbreak_apps {
            if FileManager.default.fileExists(atPath: String.init(utf8String: item)!) {
                return true
            }
        }
        return false
    }
    
    
    /// 判断当前设备是否为iPad，true:是，false:不是
    public static func isPad() -> Bool {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            return true
        }
        return false
    }
    
    
    private static let DUIDKey = "OpenUDID"
    
    /// 获取设备唯一标识
    public static let duid:String = {
        var cacheDUID:String? = nil
        
        //搜索KeyChain中是否存在DUID
        cacheDUID =  O2SCKeychainService.sharedInstance.secureDataForKey(DUIDKey) as? String

        if cacheDUID == nil {
            //生成新的DUID
            cacheDUID = idfv()
            if cacheDUID == nil {
                cacheDUID = UUID().uuidString
            }
            
            //直接写入到KeyChain中
            _ = O2SCKeychainService.sharedInstance.setSecureData(cacheDUID, forKey: DUIDKey)
        }
        
        return cacheDUID!
    }()
    
    /// 获取屏幕真实尺寸
    public static func nativeScreenSize() -> CGSize {
        let screen:UIScreen = UIScreen.main
        return CGSize(width: screen.bounds.size.width * screen.scale, height: screen.bounds.size.height * screen.scale)
    }
    
    /// 获取无线局域网的服务集标识（WIFI名称）
    public static func ssid() -> String {
        let SSIDInfo:Dictionary<String, AnyObject> = self._currentNetworkInfo()
        if let ssid:String = (SSIDInfo["SSID"] as? String) {
            return ssid
        }
        return ""
    }
    
    /// 获取基础服务集标识（站点的MAC地址）
    public static func bssid() -> String {
        let SSIDInfo:Dictionary<String, AnyObject> = self._currentNetworkInfo()
        if let bssid:String = (SSIDInfo["BSSID"] as? String) {
            return bssid
        }
        return ""
    }
    
    /// 获取开发商ID
    public static func idfv() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    /// 获取当前语言
    public static func currentLanguage() -> String? {
        let locale = Locale.preferredLanguages
        if locale.count > 0 {
            return locale.first
        }
        return nil
    }
    
    /// 获取设备IP地址
    /// - Parameter ver:
    public static func ipAddress(_ ver:O2SCIPVersion)  -> String? {
        var address: String?
        
        // get list of all interfaces on the local machine
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        guard let firstAddr = ifaddr else {
            return nil
        }
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            
            let interface = ifptr.pointee
            
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }

        freeifaddrs(ifaddr)
        return address
    }
    
    /// 获取物理内存
    public static func physicalMemory() -> Double {
        let allMemory:Double = Double(ProcessInfo.processInfo.physicalMemory)
        
        return allMemory
    }
    
    /// 获取存储大小
    public static func diskSpace() -> Int64 {
        
        var diskSpace:Int64 = 0
        let systemAttributes =  try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        if systemAttributes != nil {
            diskSpace = systemAttributes?[FileAttributeKey.systemSize] as! Int64
        }
         
        if diskSpace <= 0 {
            return -1
        }
        return diskSpace
    }
    
    /// 获取CPU类型
    public static func cpuType() -> String {
        let HOST_BASIC_INFO_COUNT = MemoryLayout<host_basic_info>.stride/MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_BASIC_INFO_COUNT)
        var hostInfo = host_basic_info()
        let result = withUnsafeMutablePointer(to: &hostInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity:Int(size)){
                host_info(mach_host_self(), Int32(HOST_BASIC_INFO), $0, &size)
            }
        }
        print(result, hostInfo)
        switch hostInfo.cpu_type {
        case CPU_TYPE_ARM:
            switch hostInfo.cpu_subtype {
            case CPU_SUBTYPE_ARM_V6:
                return "arm_V6"
            case CPU_SUBTYPE_ARM_V7:
                return "arm_V7"
            case CPU_SUBTYPE_ARM_V8:
                return "arm_V8"
            default:
                return "arm"
            }
        case CPU_TYPE_ARM64:
            switch hostInfo.cpu_subtype {
                case CPU_SUBTYPE_ARM64_V8:
                    return "arm64_V8"
                default:
                    return "arm64"
            }
        case CPU_TYPE_ARM64_32:
            return"arm64_32"
        case CPU_TYPE_X86:
            return "x86"
        case CPU_TYPE_X86_64:
            return"x86_64"
        case CPU_TYPE_ANY:
            return"any"
        case CPU_TYPE_VAX:
            return"vax"
        case CPU_TYPE_MC680x0:
            return"mc680x0"
        case CPU_TYPE_I386:
            return"i386"
        case CPU_TYPE_MC98000:
            return"mc98000"
        case CPU_TYPE_HPPA:
            return"hppa"
        case CPU_TYPE_MC88000:
            return"mc88000"
        case CPU_TYPE_SPARC:
            return"sparc"
        case CPU_TYPE_I860:
            return"i860"
        case CPU_TYPE_POWERPC:
            return"powerpc"
        case CPU_TYPE_POWERPC64:
            return"powerpc64"
        default:
            return ""
        }
    }
    
    ///获取cpu核数
    private class func cpuCount() -> Int {
        var ncpu: UInt = UInt(0)
        var len: size_t = MemoryLayout.size(ofValue: ncpu)
        sysctlbyname("hw.ncpu", &ncpu, &len, nil, 0)
        return Int(ncpu)
    }
    
    /// 获取无线局域网的强度
    /// 强度系数 3: 强 ，2：中， 1：弱 ，0：无
    public static func wifiLevel() -> Int {
        //FIXME: 未实现
        var signalStrength = 1
        let isIOS12Later = (O2SCDevice.versionCompare("12.0") != .orderedAscending)
        if isIOS12Later {
            return signalStrength
        }
        
        let app = UIApplication.shared
        //解析
        let sbar_s = O2SCCrypt.stringByBase64DecodeString("cnZicCVjYlEy", mask: base64Mask)//statusBar
        let psbar_s = O2SCCrypt.stringByBase64DecodeString("XnF3ZSRlU3IhIg==", mask: base64Mask)//_statusBar
        let sbarmodern_s = O2SCCrypt.stringByBase64DecodeString("VEtQcDFkVUMCMXNdTms0dVJe", mask: base64Mask)//UIStatusBar_Modern
        let currentadata_s = O2SCCrypt.stringByBase64DecodeString("XmF2diJ1TkQBN2ZwZmMxZEVUBDF1Yw==", mask: base64Mask)//_currentAggregatedData
        let pwifientry_s = O2SCCrypt.stringByBase64DecodeString("XnVqYjlVTkQyKQ==", mask: base64Mask)//_wifiEntry
        let pdisvalue_s = O2SCCrypt.stringByBase64DecodeString("ZWtwdDxxWWYhPHRn", mask: base64Mask)//displayValue
        let fgview_s = O2SCCrypt.stringByBase64DecodeString("Z21xYTdiT0UuNFdrZnM=", mask: base64Mask)//foregroundView
        let sbarnetworkview_s = O2SCCrypt.stringByBase64DecodeString("VEtQcDFkVUMCMXNGYnAxXkVENz9zaUpwNX12WSUn", mask: base64Mask)//UIStatusBarDataNetworkItemView
        let pwifibars_s = O2SCCrypt.stringByBase64DecodeString("XnVqYjlDVEIlPmZ2a0YxYlM=", mask: base64Mask)//_wifiStrengthBars
        
        var dataNetworkItemView:UIView?
        
        if let sbarmodernCls = NSClassFromString(sbarmodern_s!), let psbar = app.value(forKey: psbar_s!), type(of: psbar) == sbarmodernCls.class() {
            //iphonex 以后的手机
            guard let sbar = app.value(forKey: sbar_s!) as? AnyObject else {
                return signalStrength
            }
            guard let psbar = sbar.value(forKey: psbar_s!) as? AnyObject else {
                return signalStrength
            }
            guard let currentadata = psbar.value(forKey: currentadata_s!) as? AnyObject else {
                return signalStrength
            }
            guard let pwifientry = currentadata.value(forKey: pwifientry_s!) as? AnyObject else {
                return signalStrength
            }
            guard let signal = pwifientry.value(forKey: pdisvalue_s!) as? Int else {
                return signalStrength
            }
            signalStrength = signal
        } else if let sbar = app.value(forKey: sbar_s!) as? AnyObject, let fgview = sbar.value(forKey: fgview_s!) as? UIView {
            if let subviews:[UIView] = fgview.subviews {
                for subview in subviews {
                    if type(of: subview) == NSClassFromString(sbarnetworkview_s!)?.class() {
                        dataNetworkItemView = subview
                        break
                    }
                }
            }
            if let vw = dataNetworkItemView, let signal = vw.value(forKey: pwifibars_s!) as? Int {
                signalStrength = signal
            }
            
        }
        
        return signalStrength
    }
    
    //MARK: - Private Func
    
    private static func _getSysInfoByName(_ typeSpecifier:String) -> String {
        
        var size = 0
        sysctlbyname(typeSpecifier, nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname(typeSpecifier, &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    private static func _currentNetworkInfo() -> Dictionary<String, AnyObject> {
        let interfaceNames = CNCopySupportedInterfaces()
        var SSIDInfo = [String : AnyObject]()
        guard interfaceNames != nil else {
            return SSIDInfo
        }
        for interface in interfaceNames as! [CFString] {
//            print("Looking up SSID info for \(interface)") // en0
            if let info = CNCopyCurrentNetworkInfo(interface as CFString){
                SSIDInfo = info as! [String : AnyObject]
            }
//            for d in SSIDInfo.keys {
//                print("\(d): \(SSIDInfo[d]!)")
//            }
            if SSIDInfo.count > 0{
                break
            }
        }
        return SSIDInfo
    }
}
