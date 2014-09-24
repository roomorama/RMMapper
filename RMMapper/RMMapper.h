#import <Foundation/Foundation.h>

/**
 * This protocol let you control conversion between data key
 * and class properties
 */
@protocol RMMapping <NSObject>

@optional

// Allow properties to be excluded from parsing data
- (NSArray *)rm_excludedProperties;

// Mapping for properties keys to class properties
- (NSDictionary *)rm_dataKeysForClassProperties;

// Parse item within array
- (Class)rm_itemClassForArrayProperty:(NSString*)property;

@end


@interface RMMapper : NSObject

/**
 Answer from http://stackoverflow.com/questions/754824/get-an-object-attributes-list-in-objective-c/13000074#13000074
 
 Return dictionary of property name and type from a class.
 Useful for Key-Value Coding.
 */
+ (NSDictionary *)propertiesForClass:(Class)cls;

/** Populate existing object with values from dictionary
 */
+ (id) populateObject:(id)obj fromDictionary:(NSDictionary*)dict;

/** Create a new object with given class and populate it with value from dictionary
 */
+ (id) objectWithClass:(Class)cls fromDictionary:(NSDictionary*)dict;

/** Convert an object to a dictionary
 */
+ (NSDictionary*) dictionaryForObject:(id)obj;
+ (NSDictionary*) dictionaryForObject:(id)obj include:(NSArray*)includeArray;
+ (NSMutableDictionary*) mutableDictionaryForObject:(id)obj;
+ (NSMutableDictionary*) mutableDictionaryForObject:(id)obj include:(NSArray*)includeArray;


/** Convert an array of dict to array of object with predefined class
 */
+ (NSArray*) arrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray*)array;
+ (NSMutableArray*) mutableArrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray*)array;

@end
