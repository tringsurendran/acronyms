//
//  ACNetworkClient.h
//  Acronyms
//
//  Created by Surendran Thiyagarajan on 2/28/17.
//  Copyright © 2017 suren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^networkClientcompletionBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface ACNetworkClient : NSObject

- (void)get:( NSString * _Nonnull )path completionBlock:(_Nonnull networkClientcompletionBlock)callBackBlock;

@end
