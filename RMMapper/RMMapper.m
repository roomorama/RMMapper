#import "RMMapper.h"
#import <objc/runtime.h>

#ifdef DEBUG
#   define RMMapperLog(__FORMAT__, ...) NSLog(__FORMAT__, ##__VA_ARGS__)
#else
#   define RMMapperLog(...) do {} while (0)
#endif


@implementation RMMapper


static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

#define excludedFrameworkPrefixes @[@"NS", @"UI", @"CL", @"CF", @"AB", @"CA", @"CI", @"CG"]

#pragma mark - Check if class type belong to Cocoa Framework

+(BOOL)hasBasicPrefix:(NSString*)classType {
    for (NSString* prefix in excludedFrameworkPrefixes) {
        if ([classType hasPrefix:prefix]) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSArray *)systemExcludedProperties {
    return @[@"observationInfo",@"hash",@"description",@"debugDescription",@"superclass"];
}


#pragma mark - Get properties for a class
+ (NSDictionary *)propertiesForClass:(Class)cls {
    if (cls == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSArray *systemExcludedProperties = [self systemExcludedProperties];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            
            if (![systemExcludedProperties containsObject:propertyName]) {
                NSString *propertyType = [NSString stringWithUTF8String:propType];
                results[propertyName] = propertyType;
            }
        }
    }
    free(properties);
    
    // for  inheritance
    if ([cls superclass] != [NSObject class]) {
        [results addEntriesFromDictionary:[self propertiesForClass:[cls superclass]]];
    }
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

#pragma mark - Populate object from data dictionary

+(id)populateObject:(id)obj fromDictionary:(NSDictionary *)dict {
    if (obj == nil) {
        return nil;
    }
    
    // Retrieve list of items to be excluded
    NSArray* excludeArray = nil;
    if ([obj respondsToSelector:@selector(rm_excludedProperties)]) {
        excludeArray = [obj rm_excludedProperties];
    }
    
    Class cls = [obj class];
    
    // Check object for conforming RMMappingKeyPathObject,
    // and if object conform this protocol, we get mapping for this class
    NSDictionary *dataKeysForProperties = nil;
    if ([obj respondsToSelector:@selector(rm_dataKeysForClassProperties)]) {
        dataKeysForProperties = [obj rm_dataKeysForClassProperties];
    }
    
    // Retrieve property declared in class definition
    NSDictionary* properties = [RMMapper propertiesForClass:cls];
    
    // Since key of object is a string, we need to check the dict contains
    // string as key. If it contains non-string key, the key will be skipped.
    // If key is not inside the object properties, it's skipped too.
    // Otherwise assign value of key from dict to obj
    for (id dataKey in dict) {
        
        // Skip for non-string key
        if ([dataKey isKindOfClass:[NSString class]] == NO) {
            RMMapperLog(@"RMMapper: key must be NSString. Received key \"%@\"", dataKey);
            continue;
        }
        
        // If property and dataKey is different, retrieve property from dataKeysForProperties
        NSString* property = nil;
        if (dataKeysForProperties) {
            property = [[dataKeysForProperties allKeysForObject:dataKey] lastObject];
        }
        if (!property) {
            property = dataKey;
        }
        
        NSString *propertyType = properties[property];
        
        // If property doesn't belong to object, skip it
        if (propertyType == nil) {
            RMMapperLog(@"RMMapper: key \"%@\" does not exist in class or class mapping \"%@\"", property, NSStringFromClass(cls));
            continue;
        }
        
        // If key inside excludeArray, skip it
        if (excludeArray && [excludeArray containsObject:property]) {
            RMMapperLog(@"RMMapper: key \"%@\" is skipped", property);
            continue;
        }
        
        // Get value from dict from dataKey
        id value = dict[dataKey];
        
        // Do not parse NSNull
        if ([value isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        // If the property type is a custom class (not NSDictionary),
        // and the value is a dictionary,
        // convert the dictionary to object of that class
        if (![RMMapper hasBasicPrefix:propertyType] &&
            [value isKindOfClass:[NSDictionary class]]) {
            
            // Init a child attribute with respective class
            Class objCls = NSClassFromString(propertyType);
            id childObj = [[objCls alloc] init];
            [RMMapper populateObject:childObj fromDictionary:value];
            
            [obj setValue:childObj forKey:property];
        }
        
        // Else, set value for key
        else {
            // If the value is basic type and is not array, parse it directly to obj
            // http://stackoverflow.com/questions/3663266/kvc-string-conversion-not-working-for-bool-value
            if (![value isKindOfClass:[NSArray class]]) {
                @try{ [obj setValue:value forKey:property];
                }@catch(NSException * e){ // catch the exception if the value is a boolean
                    if ([e.name isEqualToString:NSInvalidArgumentException])
                        [obj setValue:@([value intValue]) forKey:property];
                }
            }
            
            // If property is NSArray or NSMutableArray, and if user provides
            // class of item within the array, parse the value to correct class
            else {
                // If the property type is NSString and the value is array,
                // join them with ","
                if ([propertyType isEqualToString:@"NSString"] \
                    && [value isKindOfClass:[NSArray class]]) {
                    NSArray* arr = (NSArray*) value;
                    NSString* arrString = [arr componentsJoinedByString:@","];
                    [obj setValue:arrString forKey:dataKey];
                }
                
                else if ([obj respondsToSelector:@selector(rm_itemClassForArrayProperty:)]) {
                    // Get the class of item inside the array
                    Class itemCls = [obj rm_itemClassForArrayProperty:property];
                    
                    // If no item class is specified, set value directly to object property
                    if (!itemCls) {
                        [obj setValue:value forKey:property];
                    } else {
                        // Process value to array with specified item class
                        NSArray* arr = [RMMapper arrayOfClass:itemCls fromArrayOfDictionary:value];
                        
                        // Set mutable array to property if propertyType is NSMutableArray
                        if ([propertyType isEqualToString:@"NSMutableArray"]) {
                            [obj setValue:[NSMutableArray arrayWithArray:arr] forKey:property];
                        }
                        
                        // Set arr to property if propertyType is NSArray
                        else if ([propertyType isEqualToString:@"NSArray"]) {
                            [obj setValue:arr forKey:property];
                        } else {
                            [obj setValue:value forKey:property];
                        }
                    }
                }
            }
        }
    }
    
    return obj;
}

+ (id)objectWithClass:(Class)cls fromDictionary:(NSDictionary *)dict {
    id obj = [[cls alloc] init];
    
    [RMMapper populateObject:obj fromDictionary:dict];
    
    return obj;
}

#pragma mark - Populate array of class from data array

+(NSArray *)arrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray *)array {
    NSMutableArray *mutableArray = [RMMapper mutableArrayOfClass:cls fromArrayOfDictionary:array];
    
    NSArray *arrWithClass = [NSArray arrayWithArray:mutableArray];
    return arrWithClass;
}

+(NSMutableArray *)mutableArrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray *)array {
    
    if (!array) {
        return nil;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    
    for (id item in array) {
        
        // The item must be a dictionary. Otherwise, skip it
        if (![item isKindOfClass:[NSDictionary class]]) {
            RMMapperLog(@"RMMapper: item inside array must be NSDictionary object");
            continue;
        }
        
        // Convert item dictionary to object with predefined class
        id obj = [RMMapper objectWithClass:cls fromDictionary:item];
        [mutableArray addObject:obj];
    }
    
    return mutableArray;
}


#pragma mark - Convert plain object to dictionary

+ (NSDictionary*) mutableDictionaryForObject:(id)obj include:(NSArray*)includeArray {
    NSDictionary* properties = [RMMapper propertiesForClass:[obj class]];
    
    NSDictionary *dataKeysForProperties = nil;
    if ([obj respondsToSelector:@selector(rm_dataKeysForClassProperties)]) {
        dataKeysForProperties = [obj rm_dataKeysForClassProperties];
    }
    
    NSMutableDictionary* objDict = [NSMutableDictionary dictionary];
    
    for (NSString* property in properties) {
        
        // If includeArray is provided, skip if the property is not inside includeArray
        if (includeArray && ![includeArray containsObject:property]) {
            RMMapperLog(@"RMMapper: key \"%@\" is skipped", property);
            continue;
        }
        
        // Get dataKey for given property
        NSString* dataKey = nil;
        if (dataKeysForProperties) {
            dataKey = dataKeysForProperties[property];
        }
        
        // Fall back to property
        if (!dataKey) {
            dataKey = property;
        }
        
        id val = [obj valueForKey:property];
        
        // If val is custom class, we will try to parse this custom class to NSDictionary
        NSString *propertyType = properties[property];
        
        if (![RMMapper hasBasicPrefix:propertyType] && val) {
            val = [RMMapper mutableDictionaryForObject:val include:nil];
        }
        
        [objDict setValue:val forKey:dataKey];
    }
    
    return objDict;
}

+ (NSMutableDictionary *)mutableDictionaryForObject:(id)obj {
    return [RMMapper mutableDictionaryForObject:obj include:nil];
}

+(NSDictionary *)dictionaryForObject:(id)obj include:(NSArray *)includeArray {
    NSMutableDictionary* dict = [RMMapper mutableDictionaryForObject:obj include:includeArray];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+(NSDictionary*)dictionaryForObject:(id)obj {
    NSMutableDictionary *mutableDict = [RMMapper mutableDictionaryForObject:obj];
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}




@end
