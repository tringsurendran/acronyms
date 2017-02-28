//
//  ACNetworkManager.m
//  Acronyms
//
//  Created by Surendran Thiyagarajan on 2/28/17.
//  Copyright © 2017 suren. All rights reserved.
//

#import "ACNetworkManager.h"

@interface ACNetworkManager ()

@property (nonatomic) ACNetworkClient *client;

@end

@implementation ACNetworkManager

+ (instancetype)sharedInstance {
    static ACNetworkManager *networkManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[ACNetworkManager alloc] init];
    });
    return networkManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.client = [[ACNetworkClient alloc] init];
    }
    return self;
}

- (void)getDetailsForAcronyms:(NSString *)acronym  completionHandler:(networkClientcompletionBlock)callBackBlock {
    NSString *urlString = [NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@", acronym];
    [self.client get:urlString completionBlock:callBackBlock];
}

@end
