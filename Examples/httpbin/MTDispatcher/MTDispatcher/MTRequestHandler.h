//
//  MTRequestHandler.h
//  

#import "MTRequest.h"

@interface MTRequestHandler : NSObject

@property (nonatomic, retain) MTRequestHandler *nextHandler;

- (void)processRequest:(MTRequest *)request;
- (void)reportRequest:(MTRequest *)request error:(NSError *)error __attribute__((objc_requires_super));

- (void)cancellAllRequestsWithOwner:(id)owner;
- (void)cancellAllRequests;

@end
