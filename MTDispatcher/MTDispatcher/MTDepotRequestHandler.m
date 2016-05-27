//
//  MTDepotRequestHandler.m
//  

#import "MTDepotRequestHandler.h"


#define LOG_DEPOT_OPERATIONS

@interface MTDepotRequestHandler()

@property (nonatomic, strong) NSMutableSet *currentRequests;

@end

@implementation MTDepotRequestHandler

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _currentRequests = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [self cancellAllRequests];
    
    self.nextHandler = nil;
}

- (void)processRequest:(MTRequest *)request
{
#ifdef LOG_DEPOT_OPERATIONS
    NSLog(@"[REQUEST DEPOT]: adding request %@", request);
#endif // LOG_DEPOT_OPERATIONS
    
    @synchronized (self)
    {
        [_currentRequests addObject:request];
    }
    
    if ([NSThread isMainThread])
    {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^(void)
                       {
                           [super processRequest:request];
                       });
    }
    else
    {
        [super processRequest:request];
    }
}

- (void)cancellAllRequestsWithOwner:(id)owner
{
#ifdef LOG_DEPOT_OPERATIONS
    NSLog(@"[REQUEST DEPOT]: cancelAllRequests owned by %@", owner);
#endif // LOG_DEPOT_OPERATIONS
    
    for (MTRequest *request in [_currentRequests allObjects])
    {
        if (request.owner == owner)
        {
#ifdef LOG_DEPOT_OPERATIONS
            NSLog(@"[REQUEST DEPOT]: cancelling request %@", request);
#endif // LOG_DEPOT_OPERATIONS
            [request cancel];
        }
    }
}

- (void)cancellAllRequests
{
#ifdef LOG_DEPOT_OPERATIONS
    NSLog(@"[REQUEST DEPOT]: cancelAllRequests called (%lu requests are in progress)", (unsigned long)_currentRequests.count);
#endif // LOG_DEPOT_OPERATIONS
    
    for (MTRequest *request in _currentRequests)
    {
#ifdef LOG_DEPOT_OPERATIONS
        NSLog(@"[REQUEST DEPOT]: cancelling request %@", request);
#endif // LOG_DEPOT_OPERATIONS
        [request cancel];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)reportRequest:(MTRequest *)request error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
#ifdef LOG_DEPOT_OPERATIONS
        NSLog(@"[REQUEST DEPOT]: removing request %@", request);
#endif // LOG_DEPOT_OPERATIONS
        
        @synchronized (self)
        {
            [_currentRequests removeObject:request];
            [super reportRequest:request error:error];
        }
    });
}
#pragma clang diagnostic pop

@end
