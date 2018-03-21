//
//  MTDepotRequestHandler.m
//  

#import "MTDepotRequestHandler.h"


@interface MTDepotRequestHandler()

@property (nonatomic, strong) NSMutableSet *currentRequests;
@property (nonatomic, assign) BOOL logDepotOperations;
@property (nonatomic, strong) NSArray<dispatch_queue_t> *serialQueues;

@end

@implementation MTDepotRequestHandler

- (id)init {
    self = [super init];
    
    if (self != nil) {
        _currentRequests = [[NSMutableSet alloc] init];
        _serialQueues = @[dispatch_queue_create("com.dispatcher.serialQueue_01", DISPATCH_QUEUE_SERIAL),
                          dispatch_queue_create("com.dispatcher.serialQueue_02", DISPATCH_QUEUE_SERIAL),
                          dispatch_queue_create("com.dispatcher.serialQueue_03", DISPATCH_QUEUE_SERIAL),
                          dispatch_queue_create("com.dispatcher.serialQueue_04", DISPATCH_QUEUE_SERIAL)];
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
    
    dispatch_async(_serialQueues[arc4random_uniform(_serialQueues.count)], ^(void) {
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
