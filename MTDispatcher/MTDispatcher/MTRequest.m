//
//  MTRequest.m
//

#import "MTRequest.h"

NSString * const MTErrorDomain = @"MTErrorDomain";

static NSTimeInterval   MTRequestTimeoutInterval        = 30;

#define IS_SUCCESSFUL_HTTP_STATUS(r)  (((r) / 100) == 2)

@interface MTRequest ()

@property (nonatomic, assign) Class responseClass;

@end

@implementation MTRequest

@synthesize responseClass = _responseClass;

+ (instancetype)requestWithOwner:(id)owner
{
    MTRequest *request = [[[self class] alloc] init];
    
    request.owner = owner;
    
    return request;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // generates empty response
        _response = [[self.responseClass alloc] init];
    }
    
    return self;
}

- (void)setCompleted:(BOOL)completed {
    if (!_completed && completed) {
        // can be completed only once, and can't be marked as processing after that
        _completed = completed;
    }
}

- (Class)responseClass __attribute__((unavailable("You should always override this")))
{
    return MTResponse.class;
}

- (NSMutableURLRequest *)serviceURLRequest;
{
    NSMutableURLRequest *networkRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@""]];
    
    // @this should be overriden if needed, or modified in subclass
    if ([networkRequest valueForHTTPHeaderField:@"Accept"] == nil)
    {
        [networkRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    
    if ([networkRequest valueForHTTPHeaderField:@"Access-Token"] == nil)
    {
        // read from globals?
        [networkRequest setValue:@"securityToken" forHTTPHeaderField:@"Access-Token"];
    }
    
    if ([networkRequest.HTTPBody length] > 0)
    {
        [networkRequest setValue:@([networkRequest.HTTPBody length]).stringValue forHTTPHeaderField:@"Content-Length"];
    }
    
    if ([networkRequest valueForHTTPHeaderField:@"Content-Type"] == nil)
    {
        [networkRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    if (networkRequest.HTTPMethod == nil)
    {
        networkRequest.HTTPMethod = @"GET";
    }
    
    networkRequest.timeoutInterval = MTRequestTimeoutInterval;
    
    return networkRequest;
}

- (void)cancel
{
    if (_canceled)
    {
        return;
    }
    
    _canceled = YES;
    
    if (_cancelBlock != nil)
    {
        _cancelBlock();
    }
}

@end

@interface MTResponse ()

@property (nonatomic, strong) NSDictionary *jsonDictionary;

@end

@implementation MTResponse

@synthesize jsonDictionary = _jsonDictionary;

- (void)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData error:(NSError *)error
{
    if (IS_SUCCESSFUL_HTTP_STATUS(networkResponse.statusCode))
    {
        // try to extract error message
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        
        if (!error)
        {
            _jsonDictionary = jsonDict;
        }
    }
    else
    {
        error = [NSError errorWithDomain:MTErrorDomain code:networkResponse.statusCode userInfo:nil];
    }
}

@end
