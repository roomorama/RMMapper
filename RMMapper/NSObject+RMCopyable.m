//
//  NSObject+TDCopy.m
//  Roomorama
//
//  Created by Roomorama on 27/12/12.
//  Copyright (c) 2012 Roomorama. All rights reserved.
//

#import "NSObject+RMCopyable.h"
#import "RMMapper.h"


@implementation NSObject (RMCopyable)

-(instancetype)copyWithZone:(NSZone *)zone {
    typeof(self) copiedObj = [[[self class] allocWithZone:zone] init];
    if (copiedObj) {
        NSDictionary* properties = [RMMapper propertiesForClass:[self class]];
        // Retrieve excluded properties
        NSArray *excludedProperties = nil;
        
        if ([self respondsToSelector:@selector(rm_excludedProperties)]) {
            excludedProperties = [self performSelector:@selector(rm_excludedProperties)];
        }
        for (NSString* key in properties) {
            if (!excludedProperties || ![excludedProperties containsObject:key]) {
                id val = [self valueForKey:key];
                [copiedObj setValue:val forKey:key];
            }
        }
    }
    return copiedObj;
}


@end
