//
//  MTHTTPBinGetSampleRequest.h
//  MTDispatcher
//
//  Created by Nick Savula on 5/27/16.
//  Copyright © 2016 Maliwan Technology. All rights reserved.
//

#import "MTRequest.h"

@class MTHTTPBinGetSampleResponse;

@interface MTHTTPBinGetSampleRequest : MTRequest

- (MTHTTPBinGetSampleResponse *)response;

@end

@interface MTHTTPBinGetSampleResponse : MTResponse

@property (nonatomic, readonly) NSString *origin;
@property (nonatomic, readonly) NSString *url;

@end
