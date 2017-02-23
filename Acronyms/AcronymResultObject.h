//
//  AcronymResultObject.h
//  Acronyms
//
//  Created by Surendran Thiyagarajan on 2/23/17.
//  Copyright © 2017 suren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AcronymResultObject : NSObject

@property (nonatomic, readonly) NSString *fullForm;
@property (nonatomic, readonly) NSString *since;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
