//
//  MTServiceRequestHandler.m
//  

#import "MTServiceRequestHandler.h"

#import "MTRequest.h"


@interface MTServiceRequestHandler ()

@property (nonatomic, strong) NSURLSession *requestSession;
@property (nonatomic, assign) BOOL logNetwork;

@end


@implementation MTServiceRequestHandler

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        self.requestSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        // load plist config
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MTDispatcher-info" ofType:@"plist"];
        NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        self.logNetwork = [plistDictionary[@"LOG_NETWORK"] boolValue];
    }
    
    return self;
}

#pragma mark - request logging

- (void)logNetworkRequest:(NSURLRequest *)request {
    NSMutableString *headerFields = [NSMutableString string];
    
    for (NSString *field in [request.allHTTPHeaderFields allKeys]) {
        [headerFields appendFormat:@"    %@: %@\n", field, [request.allHTTPHeaderFields valueForKey:field]];
    }
    
    NSString *body = request.HTTPBody.length > 0 ? (request.HTTPBody.length > 2048 ? [NSString stringWithFormat:@"    <%lu bytes>", (unsigned long)request.HTTPBody.length]
                                                    : [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]) : @"    <empty>";
    
    printf("\n----- [NETWORK REQUEST] -----\n  URL: %s\n  METHOD: %s\n  HEADER FIELDS\n%s  BODY\n%s\n-----------------------------\n",
           [request.URL.absoluteString UTF8String],
           [request.HTTPMethod UTF8String],
           [headerFields UTF8String],
           [body UTF8String]);
}

- (void)logNetworkResponse:(NSHTTPURLResponse *)response error:(NSError *)error data:(NSData *)data {
    if (error == nil) {
        printf("\n----- [NETWORK RESPONSE] -----\n  URL: %s\n  STATUS CODE: %li\n HEADER FIELDS\n%s  BODY\n    %s\n------------------------------\n",
               [response.URL.absoluteString UTF8String],
               (long)response.statusCode,
               [[response.allHeaderFields description] UTF8String],
               data.length > 0 ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] UTF8String] : [@"<empty>" UTF8String]);
    } else {
        printf("\n----- [NETWORK RESPONSE] -----\n  ERROR: %s\n", [[error localizedDescription] UTF8String]);
    }
}

#pragma mark - Common request processing methods

- (void)processRequest:(MTRequest *)request error:(NSError *)error {
    NSURLRequest *networkRequest = nil;
    
    networkRequest = [request serviceURLRequest];
    
    if (self.logNetwork) {
        [self logNetworkRequest:networkRequest];
    }
    
    if (networkRequest != nil) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSData *responseData = nil;
        
        NSURLSessionDataTask *task = [self.requestSession dataTaskWithRequest:networkRequest
                                                            completionHandler:^(NSData *data,
                                                                                NSURLResponse *response,
                                                                                NSError *error) {
                                                                responseData = data;
                                                                dispatch_semaphore_signal(semaphore);
                                                            }];
        
        if (request.cancelBlock == nil) {
            request.cancelBlock = ^{
                [task cancel];
                dispatch_semaphore_signal(semaphore);
            };
        }
        
        [task resume];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if ([request isCanceled]) {
            NSLog(@"[SERVICE REQUEST]: cancelled request %@", request);
        } else {
            if (task.error == nil) {
                [request.response parseResponse:(NSHTTPURLResponse *)task.response data:responseData error:error];
            } else {
                error = [NSError errorWithDomain:MTErrorDomain code:task.error.code userInfo:[task.error userInfo]];
            }
        }
        
        if (self.logNetwork) {
            [self logNetworkResponse:(NSHTTPURLResponse *)task.response error:task.error data:responseData];
        }
    } else {
        // invalid client state or method is not implemented
        error =[NSError errorWithDomain:MTErrorDomain code:0 userInfo:nil];
    }
    
    [super processRequest:request error:error];
}

@end
