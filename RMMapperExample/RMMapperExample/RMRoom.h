//
//  RMRoom.h
//  RMMapperExample
//
//  Created by Roomorama on 28/6/13.
//  Copyright (c) 2013 Roomorama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapper.h"
#import "RMUser.h"
#import "NSObject+RMArchivable.h"


@interface RMRoom : NSObject <RMMapping>

// The attributes is exactly same as the JSON key
@property (nonatomic, retain) NSNumber* id;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* currencyCode;
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* countryCode;
@property (nonatomic, retain) NSString* thumbnail;
@property (nonatomic, retain) NSNumber* price;
@property (nonatomic, retain) RMUser* host;

@end
