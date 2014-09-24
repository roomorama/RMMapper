//
//  RMItem.m
//  RMMapperExample
//
//  Created by Thomas Dao on 24/9/14.
//  Copyright (c) 2014 Roomorama. All rights reserved.
//

#import "RMItem.h"
#import "RMTopping.h"

@implementation RMItem

-(Class)rm_itemClassForArrayProperty:(NSString *)property {
    if ([property isEqualToString:@"topping"]) {
        return [RMTopping class];
    }
    
    return nil;
}

@end
