//
//  AcronymResultObject.m
//  Acronyms
//
//  Created by Surendran Thiyagarajan on 2/23/17.
//  Copyright © 2017 suren. All rights reserved.
//

#import "AcronymResultObject.h"

@interface AcronymResultObject ()

@property (nonatomic, readwrite) NSString *fullForm;
@property (nonatomic, readwrite) NSString *since;

@end

@implementation AcronymResultObject

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSArray *lfs = dict[@"lfs"];
        self.fullForm = [lfs firstObject][@"lf"];
        self.since = [NSString stringWithFormat:@"%@",[lfs firstObject][@"since"]];
    }
    return self;
}


@end
