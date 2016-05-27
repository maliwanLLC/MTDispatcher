//
//  MTDispatcher.h
//  

#import <Foundation/Foundation.h>
#import "MTRequest.h"


@class MTRequestHandler;
@class MTRequest;

@interface MTDispatcher : NSObject

+ (MTDispatcher *)sharedInstance;

// clue for improper use (produces compile time error)
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

- (void)processRequest:(MTRequest *)request;
- (void)cancelAllRequestsWithOwner:(id)owner;

@end
