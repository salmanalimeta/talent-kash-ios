////
////  QuickLoginModel.swift
////  Talent Cash
////
////  Created by Zohaib Baig on 08/09/2022.
////
//
//import Foundation
//#if canImport(FoundationNetworking)
//import FoundationNetworking
//#endif
//
//var semaphore = DispatchSemaphore (value: 0)
//
//let parameters = "{\n    \"email\":\"2795f2c0df2c0196\",\n    \"identity\":\"2795f2c0df2c0196\",\n    \"name\":\"Talent Cash User\",\n    \"username\":\"2795f2c0df2c0196\"\n}"
//let postData = parameters.data(using: .utf8)
//
//var request = URLRequest(url: URL(string: "https://buzzy.croxavenuesolutions.com/user/")!,timeoutInterval: Double.infinity)
//request.addValue("soft@12345", forHTTPHeaderField: "key")
//request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//request.httpMethod = "POST"
//request.httpBody = postData
//
//let task = URLSession.shared.dataTask(with: request) { data, response, error in
//  guard let data = data else {
//    print(String(describing: error))
//    semaphore.signal()
//    return
//  }
//  print(String(data: data, encoding: .utf8)!)
//  semaphore.signal()
//}
//
//task.resume()
//semaphore.wait()
