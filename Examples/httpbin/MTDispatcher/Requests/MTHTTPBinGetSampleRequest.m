//
//  MTHTTPBinGetSampleRequest.m
//  MTDispatcher
//
//  Created by Nick Savula on 5/27/16.
//  Copyright © 2016 Maliwan Technology. All rights reserved.
//

#import "MTHTTPBinGetSampleRequest.h"

#import "MTRequest_Common.h"

@implementation MTHTTPBinGetSampleResponse

- (void)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData error:(NSError *)error {
    [super parseResponse:networkResponse data:responseData error:error];
    
    if (error == nil) {
        _origin = _jsonDictionary[@"origin"];
        _url = _jsonDictionary[@"url"];
    }
}

@end

@implementation MTHTTPBinGetSampleRequest

- (NSMutableURLRequest *)serviceURLRequest {
    NSMutableURLRequest *request = [super serviceURLRequest];
    
    NSString *requestURLString = [NSMutableString stringWithFormat:@"%@/get", [self baseURLString]];
    request.URL = [NSURL URLWithString:requestURLString];
    
    return request;
}

- (MTHTTPBinGetSampleResponse *)response {
    return (MTHTTPBinGetSampleResponse *)_response;
}

- (Class)responseClass {
    return MTHTTPBinGetSampleResponse.class;
}

@end
