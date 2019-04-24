//
//  RquestNetworkData.swift
//  Pods
//
//  Created by lip on 2017/5/16.
//
//  网络请求数据处理

import UIKit
import ObjectMapper
import Alamofire

extension Notification.Name {
    public struct Network {
        /// 当服务器检测到登录授权不合法时会发送该通知
        public static let Illicit = NSNotification.Name(rawValue: "com..notification.name.network.Illicit")
        /// 当服务器停机维护时会发送该通知
        public static let HostDown = NSNotification.Name(rawValue: "com..notification.name.network.HostDown")
    }
}

/// 网络请求错误
///
/// - uninitialized: 未正常初始化
public enum RquestNetworkDataError: Error {
    case uninitialized
}

public enum NetworkError: String {
    /// 网络请求错误（非超时以外的一切错误都会抛出该值，具体错误信息会输出到控制台）
    case networkErrorFailing = "com.zhiyicx.www.network.erro.failing"
    /// 网络请求超时
    case networkTimedOut = "com.zhiyicx.www.network.time.out"
    /// 取消了请求
    case requestCanceled = "com.zhiyicx.www.network.request.canceled"
}

/// 网络请求协议
public protocol NetworkRequest {
    /// 网络请求路径
    ///
    /// - Warning: 该路径指的只最终发送给服务的路径,不包含根地址
    var urlPath: String! { set get }
    /// 网络请求方式
    var method: HTTPMethod { set get }
    /// 网络请求参数
    var parameter: [String: Any]? { set get }
    /// 相关的响应数据模型
    ///
    /// - Note: 该模型需要实现相对应的解析协议
    associatedtype ResponseModel: Mappable
}

/// 空类型
///
/// - Note: 设置 NetworkRequest.ResponseModel 为该类型表示不需要解析 ResponseModel
public struct Empty: Mappable {
    public init?(map: Map) {
    }
    public func mapping(map: Map) {
    }
}

/// 完整响应数据
public struct NetworkFullResponse<T: NetworkRequest> {
    /// 响应编号
    public let statusCode: Int
    /// 响应数据,由请求体配置的参数决定
    public var model: T.ResponseModel?
    /// 响应一组数据,由请求体配置参数决定
    public var models: [T.ResponseModel]
    /// 服务器响应数据
    public var message: String?
    /// 源数据
    public var sourceData: Any?
}

/// 网络请求结果
///
/// - success: 响应成功,返回数据
/// - failure: 响应序列化错误,返回失败原因
/// - error: 请求错误
public enum NetworkResult<T: NetworkRequest> {
    case success(NetworkFullResponse<T>)
    case failure(NetworkFullResponse<T>)
    case error(NetworkError)
}

/// 服务器响应数据
///
/// 服务器可能会响应 Dictionary<String, Any>; Array<Any>; 以及 空数组
/// 服务器指定使用空数组表示无数据的情况
/// - Warning: 当出现数据解析或者超时等错误时, 返回 nil
public typealias NetworkResponse = Any

public class RequestNetworkData: NSObject {
    private var rootURL: String?
    private let textRequestTimeoutInterval = 10
    private let serverResponseInfoKey = "message"
    var authorization: String?
    private override init() {}

    public static let share = RequestNetworkData()
    /// 配置是否显示日志信息,默认是关闭的
    ///
    /// - Note: 开启后,每次网络请求都会在控制台打印请求数据和请求结果
    public var isShowLog = false

    lazy var alamofireManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(self.textRequestTimeoutInterval)
        return Alamofire.SessionManager(configuration: configuration)
    }()

    // MARK: - config
    /// 设置请求的根地址
    ///
    /// - Parameter rootURL: 根地址字符串
    /// - Note: 设置后会导致所有的请求都依照该地址发起
    public func configRootURL(rootURL: String?) {
        self.rootURL = rootURL
    }

    /// 配置请求的授权口令
    ///
    /// - Note: 配置后,每次请求的都会携带该参数
    public func configAuthorization(_ authorization: String?) {
        self.authorization = authorization
    }

    /// 文本请求
    ///
    /// - Parameters:
    ///   - request: 请求体
    ///   - complete: 响应数据
    /// - Note: 当响应数据出现所有内容为空的情况,需要根据 statusCode 来自行决定显示的 message, 后台建议 500以上显示服务器错误,500以下显示网络错误
    public func text<T: NetworkRequest>(request: T, complete: @escaping (_ result: NetworkResult<T>) -> Void) {
        let (coustomHeaders, requestPath, encoding) = processParameters(self.authorization, request)

        var dataResponse: DataResponse<Any>!
        let decodeGroup = DispatchGroup()
        decodeGroup.enter()
        alamofireManager.request(requestPath, method: request.method, parameters: request.parameter, encoding: encoding, headers: coustomHeaders).responseJSON {  [unowned self] response in
            guard response.response != nil else {
                let error = NetworkError.networkErrorFailing
                let result = NetworkResult<T>.error(error)
                complete(result)
                return
            }

            if self.isShowLog == true {
                print("http respond info \(response)")
            }

            dataResponse = response
            decodeGroup.leave()
        }

        decodeGroup.notify(queue: DispatchQueue.main) {
            let result = dataResponse.result
            let statusCode = dataResponse.response!.statusCode

            if let error: NSError = result.error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                let error = NetworkError.networkTimedOut
                let result = NetworkResult<T>.error(error)
                complete(result)
                return
            } else if let error = result.error as NSError?, error.domain == NSURLErrorDomain && error.code != NSURLErrorTimedOut {
                let error = NetworkError.networkErrorFailing
                let result = NetworkResult<T>.error(error)
                complete(result)
                return
            }
            // 状态码正常且需要转换数据
            if statusCode >= 200 && statusCode < 300 && T.ResponseModel.self != Empty.self {
                if let datas = result.value as? [Any], let models = Mapper<T.ResponseModel>().mapArray(JSONObject: datas) {
                    let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: models, message: nil, sourceData: result.value)
                    let result = NetworkResult.success(fullResponse)
                    complete(result)
                }

                if let data = result.value as? [String: Any], let model = Mapper<T.ResponseModel>().map(JSON: data) {
                    let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: model, models: [], message: nil, sourceData: result.value)
                    let result = NetworkResult<T>.success(fullResponse)
                    complete(result)
                }
                return
            }
            // 状态码正常但是不需要转换数据
            if statusCode >= 200 && statusCode < 300 && T.ResponseModel.self == Empty.self {
                let message = self.processSuccessMessage(result: result)
                let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: message, sourceData: result.value)
                let result = NetworkResult<T>.success(fullResponse)
                complete(result)
                return
            }
            // 特殊的状态码
            if statusCode == 401 {
                NotificationCenter.default.post(name: NSNotification.Name.Network.Illicit, object: nil)
            }
            if statusCode == 503 {
                NotificationCenter.default.post(name: NSNotification.Name.Network.HostDown, object: nil)
            }
            // 错误信息的处理
            let message: String? = self.processErrorMessage(result: result)
            let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: message, sourceData: result.value)
            let resultResponse = NetworkResult<T>.failure(fullResponse)
            complete(resultResponse)
        }
    }

    private func processParameters<T: NetworkRequest>(_ authorization: String?, _ request: T) -> (HTTPHeaders, String, ParameterEncoding) {
        guard let rootURL = self.rootURL else {
            fatalError("Network request data error uninitialized, unallocate authorization.")
        }

        let requestPath = rootURL + request.urlPath
        var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
        if let authorization = self.authorization {
            let token = "Bearer " + authorization
            coustomHeaders.updateValue(token, forKey: "Authorization")
        }

        var encoding: ParameterEncoding!
        request.method == .get ? (encoding = URLEncoding.default) : (encoding = JSONEncoding.default)

        if self.isShowLog == true {
            print("\nRootURL:\(requestPath)\nAuthorization: " + (coustomHeaders["Authorization"] ?? "nil") + "\nRequestMethod:\(request.method.rawValue)\nParameters:\n\(request.parameter)\n")
        }
        return (coustomHeaders, requestPath, encoding)
    }

    /// 和服务器间的文本请求
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - path: 请求路径,拼接在根路径后
    ///   - parameter: 请求参数
    ///   - complete: 请求结果
    ///
    /// - Note:complete 返回值详细说明
    /// - responseStatus 正确: 该值为 true 时，表示服务正常想数据，NetworkResponse 按照接口约定返回不同的数据
    /// - responseStatus 错误
    ///   - 该值为 false 时: 第一种情况是请求错误(超时,数据格式错误等),该情况下 NetworkResponse 返回 NetworkError.networkErrorFailing 等值, 此时 NetworkResponse 类型为 enum
    ///   - 该值为 false 时: 第二种情况是服务器响应,但内容错误,例如服务器返回 statusCode 404 ,表示无法查询到对应数据
    ///   - 错误信息拆包: 当 responseStatus 错误时,服务器响应错误中含有服务器约定好的值‘message’时,会将对应的错误信息中的首个信息字符串通过 NetworkResponse 返回,此时 NetworkResponse 类型为 String
    /// - 所有详细的错误信息都会打印在控制台
    /// - Throws: 错误状态,如果未成功配置根地址会抛错
    @discardableResult
    public func textRequest(method: HTTPMethod, path: String?, parameter: Dictionary<String, Any>?, complete: @escaping (_ responseData: NetworkResponse?, _ responseStatus: Bool) -> Void) throws -> DataRequest {

        let (coustomHeaders, requestPath) = try processParameters(self.authorization, path)

        if self.isShowLog == true {
            let authorization: String = self.authorization ?? "nil"
            print("\nRootURL:\(requestPath)\nAuthorization: Bearer " + (authorization) + "\nRequestMethod:\(method)\nParameters:\n\(parameter)\n")
        }

        var encoding: ParameterEncoding!
        if method == .post {
            encoding = JSONEncoding.default
        } else {
            encoding = URLEncoding.default
        }

        return alamofireManager.request(requestPath, method: method, parameters: parameter, encoding: encoding, headers: coustomHeaders).responseJSON { [unowned self] response in
            if self.isShowLog == true {
                print("http respond info \(response)")
            }
            if let error: NSError = response.result.error as NSError? {
                print("http respond error \(error)")
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    complete(NetworkError.networkTimedOut, false)
                } else if error.code == NSURLErrorCancelled {
                    complete(NetworkError.requestCanceled, false)
                } else {
                    complete(NetworkError.networkErrorFailing, false)
                }
                return
            }
            var responseStatus: Bool = false
            guard let serverResponse = response.response else {
                assert(false, "服务器响应的数据无法解析")
                return
            }
            if serverResponse.statusCode >= 200 && serverResponse.statusCode < 300 {
                responseStatus = true
                complete(response.result.value, responseStatus)
                return
            }
            if serverResponse.statusCode == 401 {
                NotificationCenter.default.post(name: NSNotification.Name.Network.Illicit, object: nil)
                complete("网络请求错误", false)
                return
            }
            if serverResponse.statusCode == 503 {
                NotificationCenter.default.post(name: NSNotification.Name.Network.HostDown, object: nil)
                complete("网络请求错误", false)
                return
            }
            guard let responseInfoDic = response.result.value as? Dictionary<String, Array<String>> else {
                complete(response.result.value, responseStatus)
                return
            }
            if responseInfoDic.keys.contains(self.serverResponseInfoKey) {
                complete(responseInfoDic[self.serverResponseInfoKey]![0], responseStatus)
                return
            }
            complete(response.result.value, responseStatus)
        }
    }
    /// - Parameters:
    ///   - method: 请求方式
    ///   - path: 请求路径,拼接在根路径后
    ///   - parameter: 请求参数
    ///   - complete: 请求结果
    ///
    /// - Note:complete 返回值详细说明
    /// - responseStatus 正确: 该值为 true 时，表示服务正常想数据，NetworkResponse 按照接口约定返回不同的数据
    /// - responseStatus 错误
    ///   - 该值为 false 时: 第一种情况是请求错误(超时,数据格式错误等),该情况下 NetworkResponse 返回 NetworkError.networkErrorFailing 等值, 此时 NetworkResponse 类型为 enum
    ///   - 该值为 false 时: 第二种情况是服务器响应,但内容错误,例如服务器返回 statusCode 404 ,表示无法查询到对应数据
    ///   - 错误信息拆包: 当 responseStatus 错误时,服务器响应错误中含有服务器约定好的值‘message’时,会将对应的错误信息中的首个信息字符串通过 NetworkResponse 返回,此时 NetworkResponse 类型为 String
    /// - 所有详细的错误信息都会打印在控制台
    /// - Throws: 错误状态,如果未成功配置根地址会抛错
    public func textRequest(method: HTTPMethod, path: String?, parameter: Dictionary<String, Any>?, complete: @escaping (_ responseData: NetworkResponse?, _ responseStatus: Bool, _ statusCode: Int?) -> Void) throws -> DataRequest {
        
        let (coustomHeaders, requestPath) = try processParameters(self.authorization, path)
        
        if self.isShowLog == true {
            let authorization: String = self.authorization ?? "nil"
            print("\nRootURL:\(requestPath)\nAuthorization: Bearer " + (authorization) + "\nRequestMethod:\(method)\nParameters:\n\(parameter)\n")
        }
        
        var encoding: ParameterEncoding!
        if method == .post {
            encoding = JSONEncoding.default
        } else {
            encoding = URLEncoding.default
        }
        
        return alamofireManager.request(requestPath, method: method, parameters: parameter, encoding: encoding, headers: coustomHeaders).responseJSON { [unowned self] response in
            if self.isShowLog == true {
                print("http respond info \(response)")
            }
            if let error: NSError = response.result.error as NSError? {
                print("http respond error \(error)")
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    complete(NetworkError.networkTimedOut, false, response.response?.statusCode)
                } else {
                    complete(NetworkError.networkErrorFailing, false, response.response?.statusCode)
                }
                return
            }
            var responseStatus: Bool = false
            guard let serverResponse = response.response else {
                assert(false, "服务器响应的数据无法解析")
                return
            }
            if serverResponse.statusCode >= 200 && serverResponse.statusCode < 300 {
                responseStatus = true
                complete(response.result.value, responseStatus, serverResponse.statusCode)
                return
            }
            if serverResponse.statusCode == 401 {
                NotificationCenter.default.post(name: NSNotification.Name.Network.Illicit, object: nil)
                complete("网络请求错误", false, serverResponse.statusCode)
                return
            }
            if serverResponse.statusCode == 503 {
                NotificationCenter.default.post(name: NSNotification.Name.Network.HostDown, object: nil)
                complete("网络请求错误", false, serverResponse.statusCode)
                return
            }
            guard let responseInfoDic = response.result.value as? Dictionary<String, Array<String>> else {
                complete(response.result.value, responseStatus, serverResponse.statusCode)
                return
            }
            if responseInfoDic.keys.contains(self.serverResponseInfoKey) {
                complete(responseInfoDic[self.serverResponseInfoKey]![0], responseStatus, serverResponse.statusCode)
                return
            }
            complete(response.result.value, responseStatus, serverResponse.statusCode)
        }
    }
    private func processParameters(_ authorization: String?, _ path: String?) throws -> (HTTPHeaders?, String) {
        guard let rootURL = self.rootURL else {
            throw RquestNetworkDataError.uninitialized
        }

        var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
        if let authorization = authorization {
            let token = "Bearer " + authorization
            coustomHeaders.updateValue(token, forKey: "Authorization")
        }

        var requestPath: String = ""
        if let path = path {
            requestPath = rootURL + path
        } else {
            requestPath = rootURL
        }
        return (coustomHeaders, requestPath)
    }
    
    fileprivate func processSuccessMessage(result: Result<Any>) -> String? {
        var message: String? = nil
        
        // json -> ["message": ["value1", "value2"...]]
        if let responseInfoDic = result.value as? Dictionary<String, Array<String>>, let messages = responseInfoDic[self.serverResponseInfoKey] {
            message = messages.first
            return message
        }
        // josn -> ["message": "value"]
        if let responseInfoDic = result.value as? Dictionary<String, String>, let message = responseInfoDic[self.serverResponseInfoKey] {
            return message
        }
        // json -> ["message": ["key1": "value1", "key2": "value2"...]]
        if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, String>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
            message = messageDic.first?.value
            return message
        }
        // json -> ["message": ["key1": value1, "key2": "value2"...]]
        // { "message": { "code": 422, "msg": "Invalid uids, no valid user"} }
        if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, Any>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
            for (_, value) in messageDic.enumerated() {
                if let value = value as? String {
                    message = value
                    break
                }
            }
            return message
        }
        
        return message
    }
    
    fileprivate func processErrorMessage(result: Result<Any>) -> String? {
        var message: String? = nil
        
        // json -> ["message": ["value1", "value2"...]]
        if let responseInfoDic = result.value as? Dictionary<String, Array<String>>, let messages = responseInfoDic[self.serverResponseInfoKey] {
            message = messages.first
            return message
        }
        // josn -> ["message": "value"]
        if let responseInfoDic = result.value as? Dictionary<String, String>, let message = responseInfoDic[self.serverResponseInfoKey] {
            return message
        }
        // json -> ["message": ["key1": "value1", "key2": "value2"...]]
        if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, String>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
            message = messageDic.first?.value
            return message
        }
        // json -> ["message": ["key1": value1, "key2": "value2"...]]
        // { "message": { "code": 422, "msg": "Invalid uids, no valid user"} }
        if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, Any>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
            for (_, value) in messageDic.enumerated() {
                if let value = value as? String {
                    message = value
                    break
                }
            }
            return message
        }
        // json -> { "message": "value", "errors": { "key1": ["value1"], "key2": ["value1", "value2"]}
        // 该种类型下, errors 的第一个key 对应的 value1 显示给用户, value 信息用于开发人员开发中调试
        if let responseInfoDic = result.value as? Dictionary<String, Any> {
            if let errorDic = responseInfoDic["errors"] as? Dictionary<String, Array<String>>, let message = errorDic.first?.value.first {
                // json -> ["message":"value", "errors":["key1":"value1", "key2":"value2"]]
                return message
            } else if let responseInfo = responseInfoDic as? Dictionary<String, Array<String>>, let message = responseInfo.first?.value.first {
                // json -> ["key":["value"], "key2":["value1", "value2"]]
                return message
            } else if let message = responseInfoDic[self.serverResponseInfoKey] as? String {
                // json -> ["message": "value", other...]
                return message
            }
        }
        
        return message
    }

}
