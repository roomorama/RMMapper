//
//  RMRoom.m
//  RMMapperExample
//
//  Created by Roomorama on 28/6/13.
//  Copyright (c) 2013 Roomorama. All rights reserved.
//

#import "RMRoom.h"

@implementation RMRoom

+ (NSDictionary *)rm_mappingKeyPathsForPropertyKeys
{
    return @{
             @"countryCode" : @"country_code",
             @"currencyCode" : @"currency_code",
             };
}

@end
