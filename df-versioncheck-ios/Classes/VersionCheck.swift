//
// VersionCheck
//

import Foundation
import UIKit

// AppVersion
public struct AppVersion {
    /// appStore url
    public var url: String
    /// currentVersion
    public var currentVersion: String
    /// appStore version
    public var storeVersion: String
    /// isUpdate
    public var isUpdate: Bool
    /// version Between depth
    public var depth: Int = -1
    
    public init(url: String, currentVersion: String, storeVersion: String, isUpdate: Bool) {
        self.url = url
        self.currentVersion = currentVersion
        self.storeVersion = storeVersion
        self.isUpdate = isUpdate
    }
}

// AppStore
public class AppStore: NSObject {
    // MARK: func
    
    /**
     version Check
     - parameter identifier: String?
     - parameter handler: (AppVersion) -> Void
     */
    public static func versionCheck(_ identifier: String? = nil, handler: @escaping (AppVersion) -> Void) {
        // current version(현재 내 앱 버전 확인)
        let currentVer = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
        
        let bundleIdentifierValue = identifier ?? Bundle.main.bundleIdentifier
        
        // appStore server(앱스토어에 있는 앱 버전 확인)
        guard let bundleIdentifier = bundleIdentifierValue, let url = NSURL(string: "http://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)&t=\(Date().timeIntervalSince1970)") else {
            handler(AppVersion(url: "", currentVersion: currentVer, storeVersion: currentVer, isUpdate: false))
            return
        }
        
        // update Type
        enum UpdateType {
            case none, update, noneUpdate
        }
        
        var updateType: UpdateType = .none
        
        let task = URLSession.shared.dataTask(with: url as URL) {(data, response, error) in
            do {
                guard
                    // json 데이터 파싱 > results data parsing
                    let json = data,
                    // Specifies that the parser allows top-level objects that aren’t arrays or dictionaries.
                    let dict = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? NSDictionary,
                    let results :NSArray = dict["results"] as? NSArray, results.count != 0,
                    
                    let dic = results[0] as? NSDictionary,
                    let trackViewUrl = dic["trackViewUrl"] as? String,
                    let version = dic["version"] as? String
                else {
                        handler(AppVersion(url: "", currentVersion: currentVer, storeVersion: currentVer, isUpdate: false))
                        return
                }
                
                let currentVersion = currentVer
                
                // 현재 버전이 앱스토어에 올라가있는 버전과 다른 경우
                if currentVersion != version {
                    // 각 버전 arr 생성
                    let versionArr = version.components(separatedBy: ".")
                    let currentVersionArr = currentVersion.components(separatedBy: ".")
                    
                    // 앱스토어의 버전보다 현재 내 앱 버전이 더 높은 경우 componentCnt 정의
                    let componentCnt = versionArr.count < currentVersionArr.count ? versionArr.count: currentVersionArr.count
                    
                    for index in 0 ..< componentCnt {
                        if let av = Int(versionArr[index]), let cv = Int(currentVersionArr[index]) {
                            if av > cv {
                                // 업데이트 해야함
                                updateType = .update
                                break
                            } else if av < cv {
                                // 업데이트 할 필요 없음
                                updateType = .noneUpdate
                                break
                            }
                        }
                    }
                    
                    if updateType == .none {
                        if versionArr.count > currentVersionArr.count {
                            updateType = .update
                        } else {
                            updateType = .noneUpdate
                        }
                    }
                } else {
                    // 버전이 다르지 않으니 업데이트 할 필요 없음
                    updateType = .noneUpdate
                }
                
                if updateType == .update {
                    // update
                    var version = AppVersion(url: trackViewUrl, currentVersion: currentVersion, storeVersion: version, isUpdate: true)
                    
                    // depth
                    let currentComponent = version.currentVersion.components(separatedBy: ".")
                    let storeComponent = version.storeVersion.components(separatedBy: ".")
                    let componentsCnt = currentComponent.count
                    
                    // 현재 내 앱과 스토어 앱 버전 차이가 있다면
                    if componentsCnt != storeComponent.count {
                        version.depth = 0
                    } else {
                        for element in 0..<componentsCnt {
                            if currentComponent[element] < storeComponent[element]{
                                version.depth = element
                                break
                            }
                        }
                    }
                    
                    handler(version)
                } else {
                    // non update
                    handler(AppVersion(url: trackViewUrl, currentVersion: currentVersion, storeVersion: version, isUpdate: false))
                }
            } catch let err {
                print(err)
                handler(AppVersion(url: "", currentVersion: currentVer, storeVersion: currentVer, isUpdate: false))
            }
        }
        task.resume()
    }
}

