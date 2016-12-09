//
//  HTTPClient.swift
//  AccIdPrinter
//
//  Created by Bae on 2016. 7. 5..
//  Copyright © 2016년 nolgong. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

typealias Callback = (JSON?) -> Void

class HTTPClient: NSObject {
    static let sharedInstance = HTTPClient()
    let domain:String = "http://www.tanhacktree.com"
    
    
    private override init() {
        super.init()
    }
    
    func getMsgs(onCompletion:Callback) -> Void{
        Alamofire.request(.GET, "\(HTTPClient.sharedInstance.domain)/api/cards").responseJSON{
            response in
            switch response.result{
            case .Success(let result):
                let results = JSON(result)
                print("ENTER : \(results)")
                onCompletion(results)
            case .Failure(let error):
                print("ERROR : \(error)")
            }
        }
    }
}
