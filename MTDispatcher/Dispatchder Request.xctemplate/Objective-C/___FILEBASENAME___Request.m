//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___Request.h"

@implementation ___VARIABLE_productName:identifier___Response

- (NSError *)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData {
    NSError *error = [super parseResponse:networkResponse data:responseData];
    
    if (error == nil) {
        // Do object/core data model filling from protected variable _jsonDictionary
    }
    
    return error;
}

@end

@implementation ___VARIABLE_productName:identifier___Request

- (NSMutableURLRequest *)serviceURLRequest {
    NSMutableURLRequest *request = [super serviceURLRequest];
    
    // Do any request configuration
    
    return request;
}

- (___VARIABLE_productName:identifier___Response *)response {
    return (___VARIABLE_productName:identifier___Response *)_response;
}

- (Class)responseClass {
    return ___VARIABLE_productName:identifier___Response.class;
}

@end
