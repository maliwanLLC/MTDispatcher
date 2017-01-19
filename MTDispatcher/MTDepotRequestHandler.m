//
//  MTDepotRequestHandler.m
//  

#import "MTDepotRequestHandler.h"


@interface MTDepotRequestHandler()

@property (nonatomic, strong) NSMutableSet *currentRequests;
@property (nonatomic, assign) BOOL logDepotOperations;

@end

@implementation MTDepotRequestHandler

- (id)init {
    self = [super init];
    
    if (self != nil) {
        _currentRequests = [[NSMutableSet alloc] init];
        // load plist config
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MTDispatcher-info" ofType:@"plist"];
        NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        self.logDepotOperations = [plistDictionary[@"LOG_DEPOT_OPERATIONS"] boolValue];
    }
    
    return self;
}

#pragma mark - processing

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)processRequest:(MTRequest *)request error:(NSError *)error {
    if (self.logDepotOperations) {
        NSLog(@"[REQUEST DEPOT]: adding request %@", request);
    }
    
    @synchronized (self) {
        [_currentRequests addObject:request];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [super processRequest:request error:error];
    });
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)reportRequest:(MTRequest *)request error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (self.logDepotOperations) {
            NSLog(@"[REQUEST DEPOT]: removing request %@", request);
        }
        
        @synchronized (self) {
            [_currentRequests removeObject:request];
            [super reportRequest:request error:error];
        }
    });
}
#pragma clang diagnostic pop

#pragma mark - cancelation

- (void)cancellAllRequestsWithOwner:(id)owner {
    if (self.logDepotOperations) {
        NSLog(@"[REQUEST DEPOT]: cancelAllRequests owned by %@", owner);
    }
    
    for (MTRequest *request in [_currentRequests allObjects]) {
        if (request.owner == owner) {
            if (self.logDepotOperations) {
                NSLog(@"[REQUEST DEPOT]: cancelling request %@", request);
            }
            [request cancel];
        }
    }
}

@end
