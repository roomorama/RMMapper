//
//  RMUser.h
//  RMMapperExample
//
//  Created by Roomorama on 28/6/13.
//  Copyright (c) 2013 Roomorama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+RMArchivable.h"

@interface RMUser : NSObject

@property (nonatomic, retain) NSNumber* id;
@property (nonatomic, retain) NSString* display;
@property (nonatomic, retain) NSNumber* certified;
@end
