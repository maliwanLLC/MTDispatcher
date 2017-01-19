//
//  MTDispatcher.m
// 

#import "MTDispatcher.h"

#import "MTServiceRequestHandler.h"
#import "MTDepotRequestHandler.h"

@interface MTDispatcher ()

@property (nonatomic, strong) MTRequestHandler *headRequestHandler;

@end

@implementation MTDispatcher

#pragma mark - Singleton

+ (MTDispatcher *)sharedInstance {
    static MTDispatcher *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (sharedInstance == nil) {
        dispatch_once(&pred, ^{
            sharedInstance = [[super alloc] initUniqueInstance];
            
            sharedInstance.headRequestHandler = [[MTDepotRequestHandler alloc] init];
            MTRequestHandler *tail = sharedInstance.headRequestHandler;
            tail.nextHandler = [[MTServiceRequestHandler alloc] init];
        });
    }
    
    return sharedInstance;
}

-(instancetype) initUniqueInstance {
    return [super init];
}

#pragma mark - Request processing

- (void)processRequest:(MTRequest *)request {
    [self.headRequestHandler processRequest:request error:nil];
}

- (void)cancelAllRequestsWithOwner:(id)owner {
    [self.headRequestHandler cancellAllRequestsWithOwner:owner];
}

@end
