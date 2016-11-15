# MTDispatcher
networking engine based on chain of responsibility pattern

## Table of Contents
* [Installation](#installation)
* [Usage](#usage)
* [Configurability](#configurability)
* [Code Generation](#code-generation)

## Installation
drag and drop contents of MTDispatcher folder to your project's vendor folder

## Usage

for each request you'll need to create MTRequest subclass and MTResponse subclass. MTRequest subclass has to override - (MTResponse *)response method
with your custom response subclass

###interface
```objc
@interface MTHTTPBinGetSampleRequest : MTRequest

- (MTHTTPBinGetSampleResponse *)response;

@end
```
###implementation
```objc
- (NSMutableURLRequest *)serviceURLRequest {
    NSMutableURLRequest *request = [super serviceURLRequest];
    
    // request configuration code here
    
    return request;
}

- (MTHTTPBinGetSampleResponse *)response {
    return (MTHTTPBinGetSampleResponse *)_response;
}

- (Class)responseClass {
    return MTHTTPBinGetSampleResponse.class;
}
```

in MTResponse subclass you should override this method, to process feedback from server

```objc
- (void)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData error:(NSError *)error;
```

super call is required to fill json dictionary/array

```objc
- (void)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData error:(NSError *)error {
    [super parseResponse:networkResponse data:responseData error:error];
    
    if (error == nil) {
        _origin = _jsonDictionary[@"origin"];
        _url = _jsonDictionary[@"url"];
    }
}
```

after request/response is configured, a wannabe caller would need to import that class and MTDispatcher.h

```objc
#import "MTDispatcher.h"
#import "MTHTTPBinGetSampleRequest.h"
```

and make an actual call

```objc
MTHTTPBinGetSampleRequest *getRequest = [MTHTTPBinGetSampleRequest requestWithOwner:self];
getRequest.completionBlock = ^(MTHTTPBinGetSampleRequest *request, NSError *error) {
        if (error == nil) {
            // get parsed object(s) from request.response and do your voodoo
            // this is called in main thread, so you can safely update UI here
        }
    };
    
[[MTDispatcher sharedInstance] processRequest:getRequest];
```

## Configurability
Library is to certain extent configurable through MTDispatcher-info.plist file

```xml
<dict>
    <key>LOG_NETWORK</key>
    <false/>
    <key>PLIST_VERSION</key>
    <integer>1</integer>
    <key>TIMEOUT_INTERVAL</key>
    <integer>30</integer>
    <key>SUCESS_STATUS_CODES</key>
    <array>
        <string>200-299</string>
    </array>
    <key>HTTP_HEADERS</key>
    <dict>
        <key>Accept</key>
        <string>application/json</string>
        <key>Content-Type</key>
        <string>application/x-www-form-urlencoded</string>
    </dict>
    <key>DEFAULT_METHOD</key>
    <string>GET</string>
    <key>LOG_DEPOT_OPERATIONS</key>
    <false/>
</dict>
```

here you can configure logging options, timeout interval, accept status codes, default http headers and default request methods

## Code Generation
Dispatcher contains code generation script to create your request subclasses

###DISPATCHER_CODEGEN.sh

 how to use:
 1. copy script to some temp folder
 2. cd to that folder
 3. give script rights to write files: "chmod 755 DISPATCHER_CODEGEN.sh"
 4. run: "./DISPATCHER_CODEGEN.sh RequestName" (think FAGetArticleList)
 
 you'll see request/response templates created, just drag and drop them to your Requests folder and implement request building, response parsing
