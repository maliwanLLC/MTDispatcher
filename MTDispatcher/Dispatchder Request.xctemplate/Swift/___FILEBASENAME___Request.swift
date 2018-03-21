//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import UIKit

class ___VARIABLE_productName:identifier___Request: Request {

    class ___VARIABLE_productName:identifier___Response: Response {
        
        override func parseResponse(response: URLResponse?, data: Data?) throws {
            try super.parseResponse(response: response, data: data)
            
            //FIXME: Do object/core data model filling from variable json
        }
    }
    
    private lazy var actualResponse = ___VARIABLE_productName:identifier___Response()
    override private(set) var response: Response {
        get {
            return actualResponse
        }
        set {
            if newValue is ___VARIABLE_productName:identifier___Response {
                actualResponse = newValue as! ___VARIABLE_productName:identifier___Response
            } else {
                print("incorrect type of response")
            }
        }
    }
    
    override func serviceURLRequest() -> URLRequest {
        var request = super.serviceURLRequest()
        
        //FIXME: Do any request configuration
        
        return request
    }
}
