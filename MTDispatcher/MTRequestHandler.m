//
//  MTRequestHandler.m
//  

#import "MTRequestHandler.h"


@interface MTRequestHandler ()

@property (nonatomic, strong) MTRequestHandler *previousHandler;

@end

@implementation MTRequestHandler

- (void)setNextHandler:(MTRequestHandler *)nextHandler {
    _nextHandler = nextHandler;
    nextHandler.previousHandler = self;
}

- (void)processRequest:(MTRequest *)request {
    if (!request.completed && !request.canceled && _nextHandler != nil) {
        [_nextHandler processRequest:request];
    } else {
        // either we have no next handler (exausted the queue) or request is marked for cancelation
        // in either way we mark it as completed and finish processing
        request.completed = YES;
        [_previousHandler reportRequest:request error:nil];
    }
}

- (void)reportRequest:(MTRequest *)request error:(NSError *)error {
    if ([request isCanceled]) {
        NSLog(@"[%@]: dropping request %@", self, request);
        return;
    }
    
    if (self.previousHandler == nil) {
        if (request.completionBlock != nil) {
            request.completionBlock(request, error);
        }
    } else {
        [self.previousHandler reportRequest:request error:error];
    }
}

- (void)cancellAllRequestsWithOwner:(id)owner {
}

- (void)cancellAllRequests {
}

@end
