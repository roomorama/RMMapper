//
//  RMMappingKeyPath.h
//  RMMapperExample
//
//  Created by Kirill Kunst on 19.11.13.
//  Copyright (c) 2013 Roomorama. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This protocol gives mapping dictionary to object
 for custom fields in json vs custom properties in object
 */
@protocol RMMappingKeyPathObject <NSObject>

// Mapping for properties keys
+ (NSDictionary *)rm_dataKeysForClassProperties;

@end
