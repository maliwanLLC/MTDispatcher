//
//  MTHTTPBinGetSampleRequest.m
//  MTDispatcher
//
//  Created by Nick Savula on 5/27/16.
//  Copyright © 2016 Maliwan Technology. All rights reserved.
//

#import "MTHTTPBinGetSampleRequest.h"

@implementation MTHTTPBinGetSampleRequest

- (NSMutableURLRequest *)serviceURLRequest {
    NSMutableURLRequest *request = [super serviceURLRequest];
    
    request.HTTPMethod = @"GET";
    request.URL = [NSURL URLWithString:@"http://httpbin.org/get"];
    
    return request;
}

- (Class)responseClass {
    return MTHTTPBinGetSampleResponse.class;
}

@end

@implementation MTHTTPBinGetSampleResponse

- (void)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData error:(NSError *)error {
    [super parseResponse:networkResponse data:responseData error:error];
    
    if (error == nil) {
        _origin = _jsonDictionary[@"origin"];
        _url = _jsonDictionary[@"url"];
    }
}

@end
