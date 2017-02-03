//
//  MTRequest.m
//

#import "MTRequest.h"

NSString * const MTErrorDomain = @"MTErrorDomain";

static NSTimeInterval MTRequestTimeoutInterval;
static NSArray *MTSuccessStatuses;
static NSDictionary *MTDefaultHeaders;
static NSString *MTDefaultMethod;

bool isSuccessfulHTTPStatus(int statusCode) {
    for (NSString *codeOrRange in MTSuccessStatuses) {
        if ([codeOrRange rangeOfString:@"-"].location != NSNotFound) {
            NSArray *components = [codeOrRange componentsSeparatedByString:@"-"];
            if (components.count == 2) {
                if ([components[0] integerValue] <= statusCode && [components[1] integerValue] >= statusCode) {
                    return true;
                }
            }
        } else {
            // we have single code
            if (codeOrRange.integerValue == statusCode) {
                return true;
            }
        }
    }
    
    return false;
}

@interface MTRequest ()

@property (nonatomic, assign) Class responseClass;

@end

@implementation MTRequest

@synthesize responseClass = _responseClass;

+ (instancetype)requestWithOwner:(id)owner {
    // read defaults from plist only first time request is created
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MTDispatcher-info" ofType:@"plist"];
        NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        MTRequestTimeoutInterval = [plistDictionary[@"TIMEOUT_INTERVAL"] integerValue];
        MTSuccessStatuses = plistDictionary[@"SUCESS_STATUS_CODES"];
        MTDefaultMethod = plistDictionary[@"DEFAULT_METHOD"];
        MTDefaultHeaders = plistDictionary[@"HTTP_HEADERS"];
    });
    
    MTRequest *request = [[[self class] alloc] init];
    request.owner = owner;
    
    return request;
}

- (id)init {
    self = [super init];
    
    if (self != nil) {
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

- (MTResponse *)response __attribute__((unavailable("You should always override this"))) {
    return _response;
}

- (Class)responseClass __attribute__((unavailable("You should always override this"))) {
    return MTResponse.class;
}

- (NSMutableURLRequest *)serviceURLRequest {
    NSMutableURLRequest *networkRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@""]];
    
    [MTDefaultHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [networkRequest setValue:obj forHTTPHeaderField:key];
    }];
    
    networkRequest.HTTPMethod = MTDefaultMethod;
    networkRequest.timeoutInterval = MTRequestTimeoutInterval;
    
    return networkRequest;
}

- (void)cancel {
    if (_canceled) {
        return;
    }
    
    _canceled = YES;
    
    if (_cancelBlock != nil) {
        _cancelBlock();
    }
}

@end

@implementation MTResponse

- (NSError *)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData {
    if (isSuccessfulHTTPStatus((int)networkResponse.statusCode)) {
        // try to extract error message
        NSError *serializationError = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serializationError];
        
        if (jsonDict) {
            _jsonDictionary = jsonDict;
            return nil;
        } else {
            return [NSError errorWithDomain:MTErrorDomain
                                       code:networkResponse.statusCode
                                   userInfo:@{NSUnderlyingErrorKey : serializationError}];
        }
    } else {
        return [NSError errorWithDomain:MTErrorDomain
                                   code:networkResponse.statusCode
                               userInfo:nil];
    }
}

@end
