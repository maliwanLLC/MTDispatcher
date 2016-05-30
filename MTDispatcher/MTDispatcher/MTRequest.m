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

- (MTResponse *)response __attribute__((unavailable("You should always override this")))
{
    return _response;
}

- (Class)responseClass __attribute__((unavailable("You should always override this")))
{
    return MTResponse.class;
}

- (NSMutableURLRequest *)serviceURLRequest;
{
    NSMutableURLRequest *networkRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@""]];
    
    // should be loaded from .plist or some configuration file
    // @this should be overriden if needed, or modified in subclass
    [networkRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // read from globals?
    [networkRequest setValue:@"securityToken" forHTTPHeaderField:@"Access-Token"];
    [networkRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    networkRequest.HTTPMethod = @"GET";
    networkRequest.timeoutInterval = MTRequestTimeoutInterval;
    
    return networkRequest;
}

// @Discussion
/*
 Nick: should we add some request post-processing routine (for adding content-length, etc.)
*/

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
