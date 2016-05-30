//
//  MTRequest.h
//

#import <Foundation/Foundation.h>

#import "MTDispatcher.h"

@class MTRequest;
@class MTResponse;

/*!
 @abstract The error domain for all errors from MTDispatcher.
 @discussion Error codes from the SDK in the range 1000-1099 are reserved for this domain.
 */
extern NSString * const MTErrorDomain;

/*!
 @enum MTDispatcher-related Error Codes
 @abstract Constants used by NSError to indicate errors in the MTDispatcher domain
 */
NS_ENUM(NSInteger)
{
    MTErrorUnknown = 			-1,
    MTErrorSerializationFailed   =     1001,
    MTErrorMappingFailed = 1002,
    MTErrorTooFewParametersToFillModel = 1003
};

// would prefer 'instancetype' instead of id here
// but alas 'Unknown type name 'instancetype''
// opened radar: http://www.openradar.me/radar?id=1517409
typedef void (^MTRequestCompletionBlock)(id request, NSError *error);
typedef void (^MTRequestCancelBlock)();

@interface MTRequest : NSObject {
    @protected
    Class _responseClass;
    MTResponse *_response;
}

@property (nonatomic, strong) id owner;

@property (nonatomic, readonly, getter = isCanceled) BOOL canceled;
@property (nonatomic, assign) BOOL completed;

@property (nonatomic, copy) MTRequestCancelBlock cancelBlock;
@property (nonatomic, copy) MTRequestCompletionBlock completionBlock;

+ (instancetype)requestWithOwner:(id)owner;

- (NSMutableURLRequest *)serviceURLRequest __attribute__((objc_requires_super));
- (MTResponse *)response;
- (void)cancel;

@end

@interface MTResponse : NSObject {
    @protected
    NSDictionary *_jsonDictionary;
}

- (void)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData error:(NSError *)error __attribute__((objc_requires_super));

@end
