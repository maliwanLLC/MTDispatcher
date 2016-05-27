//
//  ViewController.m
//  MTDispatcher
//
//  Created by Nick Savula on 6/18/15.
//  Copyright (c) 2015 Maliwan Technology. All rights reserved.
//

#import "ViewController.h"

#import "MTDispatcher.h"
#import "MTHTTPBinGetSampleRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    MTHTTPBinGetSampleRequest *getRequest = [MTHTTPBinGetSampleRequest requestWithOwner:self];
    getRequest.completionBlock = ^(MTRequest *request, NSError *error) {
        if (error == nil) {
            NSLog(@"%@", ((MTHTTPBinGetSampleResponse *)((MTHTTPBinGetSampleRequest *)request).response).origin);   /// how to get rid of this
            NSLog(@"%@", ((MTHTTPBinGetSampleResponse *)((MTHTTPBinGetSampleRequest *)request).response).url);     //   huge cast?
        }
    };
    
    [[MTDispatcher sharedInstance] processRequest:getRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
