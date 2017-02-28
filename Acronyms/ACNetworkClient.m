//
//  ACNetworkClient.m
//  Acronyms
//
//  Created by Surendran Thiyagarajan on 2/28/17.
//  Copyright © 2017 suren. All rights reserved.
//

#import "ACNetworkClient.h"

@interface  ACNetworkClient ()

@property (nonatomic) NSURLSession *urlSession;

@end

@implementation ACNetworkClient

- (instancetype)init {
    self = [super init];
    if (self) {
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (void)get:(NSString *)path completionBlock:(networkClientcompletionBlock)callBackBlock {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    request.HTTPMethod = @"GET";
    [self sendRequest:request callBack:callBackBlock];
}

- (void)sendRequest:(NSMutableURLRequest *)request callBack:(networkClientcompletionBlock)callBackBlock {
    [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        callBackBlock(data,response,error);
    }] resume];
}


@end
