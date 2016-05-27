//
//  MTServiceRequestHandler.m
//  

#import "MTServiceRequestHandler.h"

#import "MTRequest.h"


#define LOG_NETWORK


@interface MTServiceRequestHandler ()
{
    // general session is general
    NSURLSession *requestSession_;
}

@end


@implementation MTServiceRequestHandler

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        requestSession_ = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    
    return self;
}

#pragma mark - request logging

- (void)logNetworkRequest:(NSURLRequest *)request
{
    NSMutableString *headerFields = [NSMutableString string];
    
    for (NSString *field in [request.allHTTPHeaderFields allKeys])
    {
        [headerFields appendFormat:@"    %@: %@\n", field, [request.allHTTPHeaderFields valueForKey:field]];
    }
    
    NSString *body = request.HTTPBody.length > 0 ? (request.HTTPBody.length > 2048 ? [NSString stringWithFormat:@"    <%lu bytes>", (unsigned long)request.HTTPBody.length]
                                                    : [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]) : @"    <empty>";
    
    NSLog(@"\n----- [NETWORK REQUEST] -----\n  URL: %@\n  METHOD: %@\n  HEADER FIELDS\n%@  BODY\n%@\n-----------------------------\n",
          request.URL,
          request.HTTPMethod,
          headerFields,
          body);
}

- (void)logNetworkResponse:(NSHTTPURLResponse *)response error:(NSError *)error data:(NSData *)data
{
    if (error == nil)
    {
        NSLog(@"\n----- [NETWORK RESPONSE] -----\n  URL: %@\n  STATUS CODE: %li\n HEADER FIELDS\n%@  BODY\n    %@\n------------------------------\n",
              response.URL,
              (long)response.statusCode,
              response.allHeaderFields,
              data.length > 0 ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"<empty>");
    }
    else
    {
        NSLog(@"\n----- [NETWORK RESPONSE] -----\n  ERROR: %@\n", [error localizedDescription]);
    }
}

#pragma mark - Common request processing methods

- (void)processRequest:(MTRequest *)request
{
    NSURLRequest *networkRequest = nil;
    NSError *error = nil;
    
    networkRequest = [request serviceURLRequest];
    
#ifdef LOG_NETWORK
    [self logNetworkRequest:networkRequest];
#endif // LOG_NETWORK
    
    if (networkRequest != nil)
    {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSData *responseData = nil;
        
        NSURLSessionDataTask *task = [requestSession_ dataTaskWithRequest:networkRequest
                                                        completionHandler:^(NSData *data,
                                                                            NSURLResponse *response,
                                                                            NSError *error) {
                                                            responseData = data;
                                                            dispatch_semaphore_signal(semaphore);
                                                        }];
        
        if (request.cancelBlock == nil)
        {
            request.cancelBlock = ^
            {
                [task cancel];
                dispatch_semaphore_signal(semaphore);
            };
        }
        
        [task resume];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if ([request isCanceled])
        {
            NSLog(@"[SERVICE REQUEST]: cancelled request %@", request);
        }
        else
        {
            if (task.error == nil) {
                [request.response parseResponse:(NSHTTPURLResponse *)task.response data:responseData error:error];
            } else {
                error = [NSError errorWithDomain:MTErrorDomain code:task.error.code userInfo:[task.error userInfo]];
            }
        }
        
#ifdef LOG_NETWORK
        [self logNetworkResponse:(NSHTTPURLResponse *)task.response error:task.error data:responseData];
#endif // LOG_NETWORK
    }
    else
    {
        // invalid client state or method is not implemented
        error =[NSError errorWithDomain:MTErrorDomain code:0 userInfo:nil];
    }
    
    // feedback
    [super reportRequest:request error:error];
}

@end
