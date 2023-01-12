
//
//  NetworkUtil.swift
//  FontsApp
//
//  Created by Rao Mudassar on 18/06/2021.
import Foundation
import Alamofire
import UIKit

enum NetworkError:String {
    case serverError = "Server Error"
    case InternetNotAvailable = "The internet connection appears to be offline."
    case SystemError = "Internal System Error"
}

class NetworkUtil : NSObject {

    static let shared = NetworkUtil()

      class func isConnectedToInternet() -> Bool {
            return NetworkReachabilityManager()?.isReachable ?? false
        }
    
    private override init(){}

    private func makeGetRequest(url: String) -> URLRequest? {
        guard let urlObj = URL(string: url) else {return nil}
        var request = URLRequest(url: urlObj)
        request.httpMethod = "GET"
        return request
    }

    private func makePOSTRequest(url: String, params: [String], paramURL: String) -> URLRequest? {
        guard let urlObj = URL(string: url) else {return nil}
        var request = URLRequest(url: urlObj)
        request.httpMethod = "POST"
        let paramString = paramURL.addParams(params: params)
        request.httpBody = paramString.data(using:String.Encoding.ascii, allowLossyConversion: false)
        return request
    }
    
    
    
    typealias successHandler  = ((Any?)->(Void))
    typealias errorHandler = (NSError?) -> Void
    
    // When you want to pass header after Login
    
    class func request(apiMethod : String , parameters : Parameters? , requestType : HTTPMethod = .post , showProgress : Bool = false , encoding: ParameterEncoding = JSONEncoding.default , view : UIView? = nil , onSuccess : @escaping successHandler , onFailure : @escaping (NetworkError,String)->() ) {
        print("\n\nRequest Url = ",apiMethod)
        print("Request form params = \(parameters?.count ?? 0)")
        parameters?.forEach({ k,v in
            print("\(k) = \(v)")
        })
        if self.isConnectedToInternet() == true {
            var headers: HTTPHeaders? = [ "Authorization": "Bearer "+UserDefaultManager.instance.jwtToken]
            if UserDefaultManager.instance.jwtToken != ""{
                
               headers = [ "Authorization": "Bearer "+UserDefaultManager.instance.jwtToken,"key": "soft@12345"]
            }else{
                headers = ["key": "soft@12345"]
            }

            AF.request(apiMethod, method: requestType, parameters: parameters, encoding: encoding, headers: headers).responseData { (response) in
                print(response)
                switch response.result {
                case .success(let value):
                    print("\n\nResponse = ",String(data: value, encoding: .utf8) ?? "","\n\n")
                    if let httpStatusCode = response.response?.statusCode {
                     
                        switch httpStatusCode {
                            //SUCCESS
                        case 200,201,204:
                            onSuccess(value)
                        
                        default:
                            onFailure(NetworkError.serverError,NetworkError.serverError.rawValue)
                        }
                    }
                case .failure(let error):
                    print(error)
        
                    onFailure(NetworkError.SystemError,error.localizedDescription)
                }
            }
        }else{
            onFailure(NetworkError.InternetNotAvailable,NetworkError.InternetNotAvailable.rawValue)
        }
    }
    
    class func request<T: Decodable>(dataType:T.Type,apiMethod : String , parameters : Parameters? = nil , requestType : HTTPMethod = .get, onSuccess : @escaping (T)->() , onFailure : @escaping (NetworkError,String)->()) {
        NetworkUtil.request(apiMethod: apiMethod, parameters: parameters,requestType: requestType, onSuccess: {data in
            guard let data = data as? Data else{
                onFailure(NetworkError.SystemError,NetworkError.SystemError.rawValue)
                return
            }
            do{
            let t = try JSONDecoder().decode(dataType, from: data)
            onSuccess(t)
            }catch let e{
                print("error = ",e)
                let dic = try? JSONSerialization.jsonObject(with: data,options: .mutableContainers) as? [String:Any]
                if let message = dic?["message"] as? String {
                    onFailure(NetworkError.SystemError,message)
                }else if let error = dic?["error"] as? String {
                    onFailure(NetworkError.SystemError,error)
                }else{
                    onFailure(NetworkError.SystemError,NetworkError.SystemError.rawValue)
                }
            }
        }, onFailure: onFailure)
    }
    
    // Without header as you are using login
    
    class func loginRequest(apiMethod : String , parameters : Parameters? , requestType : HTTPMethod = .post , showProgress : Bool = false , encoding: ParameterEncoding = JSONEncoding.default , view : UIView? = nil , onSuccess : @escaping successHandler , onFailure : @escaping (String)->() ) {
      
        if self.isConnectedToInternet() == true {
            
        var headers: HTTPHeaders? = [ "Authorization": "Bearer "+UserDefaultManager.instance.jwtToken,"key": "soft@12345"]
            
            if UserDefaultManager.instance.jwtToken != ""{
                
               headers = [ "Authorization": "Bearer "+UserDefaultManager.instance.jwtToken]
            }else{
                headers = [ "key": "soft@12345"]
            }

            AF.request(apiMethod, method: requestType, parameters: parameters, encoding: encoding, headers: headers).responseJSON { (response) in
             
                switch response.result {
                case .success(let value):
                    
                    if let httpStatusCode = response.response?.statusCode {
                     
                        switch httpStatusCode {
                            //SUCCESS
                        case 200,201,204:
                            onSuccess(value)
                        
                        default:
                            onFailure("Invalid Credentials")
                        }
                    }
        
                case .failure(let error):
                    print(error)
        
                    onFailure(error.localizedDescription)
                }
                
                
            }
            
        }else{
            
            onFailure("The internet connection appears to be offline.")
        }
        
    }
    
    // media Upload Api
    
    class func mulitiparts(apiMethod : String,ServerImage:[UIImage] , parameters : [String:Any] , requestType : HTTPMethod = .post , showProgress : Bool = false , encoding: ParameterEncoding = JSONEncoding.default , view : UIView? = nil , onSuccess : @escaping successHandler , onFailure : @escaping (String)->() ) {
      
        if self.isConnectedToInternet() == true {
        print(ServerImage.count)
        
        print(ServerImage)
        
        var count:Int = 0
            var headers: HTTPHeaders? = [ "Authorization": "Bearer "+UserDefaultManager.instance.jwtToken]
            
            if UserDefaultManager.instance.jwtToken != ""{
                
               headers = [ "Authorization": "Bearer "+UserDefaultManager.instance.jwtToken,"key": "soft@12345"]
            }else{
                headers = [ "key": "soft@12345"]
            }
      
        AF.upload(multipartFormData: { (multipartFormData) in
                
                for (key, value) in parameters {
                    multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
                
                
            guard let imgData = ServerImage[0].jpegData(compressionQuality: 0.25) else { return }
            guard let imgProfileDate = ServerImage[1].jpegData(compressionQuality: 0.25) else { return }
        multipartFormData.append(imgData, withName: "profileImage", fileName: "profileImage.jpeg", mimeType: "image/jpeg")
            multipartFormData.append(imgProfileDate, withName: "coverImage", fileName: "coverImage.jpeg", mimeType: "image/jpeg")
                
        },to: URL.init(string: apiMethod)!, usingThreshold: UInt64.init(),
                  method: .patch,
                  headers: headers).response{ response in
            
                switch response.result {
                case .success(let value):
                    
                    onSuccess(value)

                case .failure(let error):
                    print(error)
            
                    onFailure(error.localizedDescription)
                }
            }
        }else{
            onFailure("The internet connection appears to be offline.")
            
        }
    }
    
    
//    private class func authorizationHeaders()-> HTTPHeaders? {
//
//
//        authorizationHeaders("Bearer \(bearerToken)")
//
//        //var headers : HTTPHeaders = [:]
//        //headers["Content-Type"] = "application/json"
//        return headers
//
//    }
    
}
