#!/bin/bash
# Generates teplete reqeust/response interfaces for MTDispatcher
#
# how to use:
# 1. copy script to some temp folder
# 2. cd to that folder
# 3. give script rights to write files: chmod 755 DISPATCHER_CODEGEN.sh
# 4. run: ./DISPATCHER_CODEGEN.sh RequestName (think FAGetArticleList)

reqeust_name=$1

if [ "$reqeust_name" != "" ]; then
	echo "Creating phisical files"
	echo "..."
	author=$(cat ~/.gitconfig | grep "name =" | cut -d'=' -f 2)
    date=$(date +%F)
    request=$(echo "Request")
    file=$(echo "$reqeust_name$request")
    response=$(echo "Response")

    touch "$file.h"
    echo "//
//  $file.h
//
//  Created by $author on $date.
//

#import \"MTRequest.h\"

@interface $reqeust_name$response : MTResponse

@end

@interface $file : MTRequest

- ($reqeust_name$response *)response;

@end

    " > $file.h
    echo "$file.h has been created"

    touch "$file.m"
    echo "//
//  $file.m
//
//  Created by $author on $date.
//

#import \"$file.h\"

@implementation $reqeust_name$response

- (void)parseResponse:(NSHTTPURLResponse *)networkResponse data:(NSData *)responseData error:(NSError *)error {
    [super parseResponse:networkResponse data:responseData error:error];
    
    if (error == nil) {
    	// Do object/core data model filling from protected variable _jsonDictionary
    }
}

@end

@implementation $file

- (NSMutableURLRequest *)serviceURLRequest {
    NSMutableURLRequest *request = [super serviceURLRequest];
    
    // Do any request configuration
    
    return request;
}

- ($reqeust_name$response *)response {
    return ($reqeust_name$response *)_response;
}

- (Class)responseClass {
    return $reqeust_name$response.class;
}

@end

    " > $file.m
    echo "$file.m has been created"

    else
    echo "[ERROR!] Provide VIPER module name"
    echo "Call this script with at least 1 parameter"
    echo "sh VIPER_GEN NewModuleName"
    exit 0
fi