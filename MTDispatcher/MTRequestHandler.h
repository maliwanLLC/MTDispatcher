//
//  MTRequestHandler.h
//  

#import "MTRequest.h"

@interface MTRequestHandler : NSObject

@property (nonatomic, retain) MTRequestHandler *nextHandler;

/*
 @discussion
 process request method was updated to include error message,
 now if one of handlers detects error early, the request won't even
 be forwarded to next handler and will be reported early with error
 */
- (void)processRequest:(MTRequest *)request error:(NSError *)error __attribute__((objc_requires_super));
- (void)reportRequest:(MTRequest *)request error:(NSError *)error __attribute__((objc_requires_super));

- (void)cancellAllRequestsWithOwner:(id)owner;

@end
