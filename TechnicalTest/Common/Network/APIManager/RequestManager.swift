//
//  RequestManager.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import Foundation
import Alamofire
import MobileCoreServices
import UIKit
import SystemConfiguration

protocol UploadProgressDelegate {
    func didReceivedProgress(progress:Float)
}

protocol DownloadProgressDelegate {
    func didReceivedDownloadProgress(progress:Float, filename:String)
    func didFailedDownload(filename:String)
}

public protocol EndPointType {
    
    // MARK: - Vars & Lets
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var url: URL { get }
    var encoding: ParameterEncoding { get }
    var version: String { get }
    var folderPath: String { get }
    
}

public class RequestManager {
    
    // MARK: - Vars & Lets
    var delegate : UploadProgressDelegate?
    var downloadDelegate : DownloadProgressDelegate?
    
    private let sessionManager: SessionManager
    private let retrier: RequestManagerRetrier
    public static var networkEnvironment: NetworkEnvironment = .dev
    
    // MARK: - Public methods
    
    public func call<T>(type: RequestItemsType, params: Parameters? = nil, queryParameter: Parameters? = nil, pathParameters: String? = nil, handler: @escaping (Swift.Result<T, AlertMessage>) -> Void) where T: Codable {
        guard ReachabilityManager.isConnectedToNetwork() else{
            self.resetNumberOfRetries()
            return handler(.failure(AlertMessage.noInternetConnection()))
        }
        var requestURL = type.url
        if let pathParam = pathParameters{
            requestURL = URL(string: requestURL.description + pathParam)!
        }
        if let queryParam = queryParameter{
            for key in queryParam.keys{
                if let url = requestURL.appendParameters(whereKey: key, value: queryParam[key]){
                    requestURL = url
                }
            }
        }
        self.sessionManager.request(
            requestURL,
            method: type.httpMethod,
            parameters: params,
            encoding: type.encoding,
            headers: type.headers).validate().responseJSON { (data) in
                if data.response?.statusCode == 200{
                    do{
                        guard let jsonData = data.data else {
                            throw AlertMessage.noDataFound()
                        }
                        let result = try JSONDecoder().decode(T.self, from: jsonData)
                        handler(.success(result))
                        self.resetNumberOfRetries()
                    } catch let error{
                        print(error.localizedDescription)
                        handler(.failure(self.parseApiError(data: data.data, error: error)))
                    }
                }else{
                    do{
                        guard data.data != nil else {
                            throw AlertMessage.noDataFound()
                        }
                        handler(.failure(AlertMessage.somethingWentWrong()))
                    } catch let error{
                        print(error.localizedDescription)
                        handler(.failure(self.parseApiError(data: data.data, error: error)))
                    }
                }
            }
    }
    
    public func cancelAllRequest(){
        self.sessionManager.session.getAllTasks { (task) in
            task.forEach{$0.cancel()}
        }
    }
    
    public func setNumberOfRetries(number : Int){
        self.retrier.numberOfRetries = number
    }
    // MARK: - Private methods
    
    private func resetNumberOfRetries() {
        self.retrier.numberOfRetries = 0
    }
    
    private func parseApiError(data: Data?, error: Error?) -> AlertMessage {
        let decoder = JSONDecoder()
        if let jsonData = data, let error = try? decoder.decode(NetworkError.self, from: jsonData) {
            return AlertMessage(body: error.key ?? error.message)
        }else if let e = error{
            return AlertMessage(body: e.localizedDescription)
        }
        return AlertMessage.somethingWentWrong()
    }
    
    // MARK: - Initialisation
    
    public init(sessionManager: SessionManager = SessionManager(), retrier: RequestManagerRetrier = RequestManagerRetrier()) {
        self.sessionManager = sessionManager
        self.retrier = retrier
        self.sessionManager.retrier = self.retrier
    }
    
}

//MAARK:- URL Extension
extension URL {
    
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
    
    func getMimeType() -> String {
        let fileExtension = pathExtension as CFString
        guard let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil)?.takeUnretainedValue() else {
            return ""
        }
        guard let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType) else {
            return ""
        }
        let mimeType = convertCFTypeToString(cfValue: mimeUTI) ?? ""
        return mimeType
    }
    
    private func convertCFTypeToString(cfValue: Unmanaged<CFString>!) -> String?{
        let value = Unmanaged.fromOpaque(cfValue.toOpaque()).takeUnretainedValue() as CFString
        if CFGetTypeID(value) == CFStringGetTypeID(){
            return value as String
        } else {
            return nil
        }
    }
    
    func appendParameters(whereKey queryItem: String, value: Any?) -> URL? {
        guard var urlComponents = URLComponents(string: absoluteString) else { return nil}
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: queryItem, value: "\(value ?? "")")
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}

public class AlertMessage: Error {
    
    // MARK: - Vars & Lets
    public var title = ""
    public var body = ""
    public var isDismissRequired = false
    public var isPopRequired = false
    
    // MARK: - Initialization
    
    public init(){
        
    }
    
    public init(title: String = "Error!", body: String, isPopRequired: Bool = false, isDismissRequired: Bool = false) {
        self.title = title
        self.body = body
        self.isPopRequired = isPopRequired
        self.isDismissRequired = isDismissRequired
    }
    
    func showAlert(controller: UIViewController){
        let alertController = UIAlertController(title: self.title, message: self.body, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func noInternetConnection() -> AlertMessage{
        AlertMessage(body: "No internet connection")
    }
    
    static func authorizationFailure() -> AlertMessage{
        AlertMessage(body: "Autorisation Failure!")
    }
    
    static func noDataFound() -> AlertMessage{
        AlertMessage(body: "No Data Found!")
    }
    
    static func somethingWentWrong() -> AlertMessage{
        AlertMessage(body: "Something went wrong")
    }
}

public class NetworkError: Codable {
    
    let message: String
    let key: String?
}

public enum ResponseType : Int{
    case success = 1
    case failure = 0
}

public class ReachabilityManager {

    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
