//
//  ACNetworkManager.h
//  Acronyms
//
//  Created by Surendran Thiyagarajan on 2/28/17.
//  Copyright © 2017 suren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkClient.h"

@interface ACNetworkManager : NSObject

+ (instancetype)sharedInstance;

- (void)getDetailsForAcronyms:(NSString *)acronym  completionHandler:(networkClientcompletionBlock)callBackBlock;

@end
