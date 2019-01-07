//
//  DataModel.swift
//  Engu
//
//  Created by Daeho on 2017. 2. 21..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import Foundation

class TestDataModel {
    func getJsonData(stagecount: String, completionHandler : @escaping((_ jsonData : [String : AnyObject]?) -> Void)){
        
        let url = URL(string: "http://localhost:3000/app/getList?type=MID&id="+stagecount)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return completionHandler(nil)
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                //연결은됬는데 다른쪽에서 에러가 났을 경우
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(String(describing: response))")
                return completionHandler(nil)
            }else {
                let responseData = String(data: data!, encoding: .utf8)?.data(using: .utf8)
                //print("response = \(String(describing: response))")
                do {
                    if let data = responseData,
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String: AnyObject]
                    {
                        return completionHandler(json)
                    } else {
                        print("No Data :/")
                        return completionHandler(nil)
                    }
                } catch {
                    // 실패한 경우, 오류 메시지를 출력합니다.
                    print("Error, Could not parse the JSON request")
                    return completionHandler(nil)
                }
            }
        }
        task.resume()
    }
}
