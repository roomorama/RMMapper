Setup
========
You can drag the RMMapper folder to your project. This library must be ARC enabled.

RMMapper can be installed by CocoaPods. Add below line to your Podfile to install it.

```
pod 'RMMapper',       '~> 1.0.0'
```

Usage
=====

This library converts common data structure like NSDictionary or NSArray into objects with predefined class. It is similar to Jackson or Gson library in Java.

One common use case for developer is retrieving the data from server, and populating it to the views. If you use AFNetworking, it already converts the string into NSDictionary or NSArray, and you can use that to build your view.

Let's assume we retrieve a user json like this:

```
{
  "id": 50234
  "name":"David",
  "age":40,
  "email":"david@gmail.com"
}
```

We can build the view by:

```
self.nameLabel.text = [dict objectForKey:@"name"];
self.ageLabel.text = [dict objectForKey:@"age"];
self.emailLabel.text = [dict objectForKey:@"email"];
```

This approach is okay but not scalable. Response from server can contains 20 or more different keys, and typing [dict objectForKey:@"key"] is tedious and error prone. If we type wrong key string, the app will crash! The compiler cannot help us detect error, and we can only find these crash when we do actual test at runtime. If we need to pass the data to another controller, we will have more repetitive tasks to do. And worse, if in the future server includes more attributes, then we have to edit all the ViewControllers to add the extra attributes.

So we have to find a better approach. This time we define a plain model class and convert the NSDictionary/NSArray into the plain model object when we retrieve data from server. Then in the view, we can simply use that class and XCode can autocomplete the fields for us.

Let define an user class to model above json:

```
// RMUser.h

@interface RMUser : NSObject

@property (nonatomic, retain) NSNumber* id;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, retain) NSNumber* age;

@end
```

In the view, it becomes:

```
self.nameLabel.text = user.name;
self.ageLabel.text = [user.age stringValue];
self.emailLabel.text = user.email;
```

Well this is much cleaner! We have XCode auto complete the fields for us, so we don't have to worry about the wrong key like in previous approach. But we still need to convert the data into this object:

```
RMUser* user = [[RMUser alloc] init];
user.name = [dict objectForKey:@"name"];
user.age = [dict objectForKey:@"age"];
user.email = [dict objectForKey:@"email"];
// Continue to parse the value...
```

Doing above code is boring and luckily we have a better way to do it. If we can retrieve attributes for an object, we can use ```setValue:forKey``` method to set value from dictionary to object attribute.

Using RMMapper, the above code becomes super simple:

```
RMUser* user = [RMMapper objectWithClass:[RMUser class] fromDictionary:dict];
```

Then all value from dictionary will be parsed into object user!


Behind the scene
================

What happen behind the scene: RMMapper retrieves attributes from the class. For each attribute, it gets the value from dict with the same key, and if existed, set the value to object attribute.

So in order for RMMapper to work, we must define our class with attributes the same as JSON key we get from server. As above example, id, name, age, email is key taken directly from JSON string.

Methods
=======

You can retrieve list of attributes of a class by:

```
+ (NSDictionary *)propertiesForClass:(Class)cls;
```

If you have an object and you want to populate it's attributes from a dictionary, there is a method for that:

```
+ (id) populateObject:(id)obj fromDictionary:(NSDictionary*)dict;
```

If you want to exclude some certain attributes, just create an NSArray contains the attributes string as parameter for exclude:

```
+ (id) populateObject:(id)obj fromDictionary:(NSDictionary*)dict exclude:(NSArray*)excludeArray;
```

There is a use case that you need to build NSDictionary params for AFNetworking:

```
+ (NSDictionary*) dictionaryForObject:(id)obj;
+ (NSDictionary*) dictionaryForObject:(id)obj include:(NSArray*)includeArray;
+ (NSMutableDictionary*) mutableDictionaryForObject:(id)obj;
+ (NSMutableDictionary*) mutableDictionaryForObject:(id)obj include:(NSArray*)includeArray;
```

You can convert an object to NSDictionary so that NSLog can print its value too!

If the json is an array, we can also convert the NSArray of dictionary into NSArray of object with predefined class. You can see the example for more detail.

```
+ (NSArray*) arrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray*)array;
+ (NSMutableArray*) mutableArrayOfClass:(Class)cls fromArrayOfDictionary:(NSArray*)array;
```

RMMapper supports relationship in your class as well. Lets assume we now have JSON for a room as below:

```
{
  "id":879302,
  "title":"My room",
  "address":"Singapore",
  "host":{"id":34045, "name":"David", "age":30, "email":"david@gmail.com"}
}
```

You can define class RMRoom as below:

```
// RMRoom.h
#import "RMUser.h"

@interface RMRoom : NSObject

@property (nonatomic, retain) NSNumber* id;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) RMUser* host;

@end
```

Then if you want to access the host email, you can use ```room.host.email```


Usage of RMMapper
=================

RMMapper is very helpful when you want to archive custom object into NSUserDefaults, or make an object copyable. 

If you want to make RMUser class archivable so that you can save it into NSUserDefaults, just add this into the header: 

```#import "NSObject+RMArchivable.h"``` 

Then done, your class is ready to be archived! You can use category NSUserDefaults+RMSaveCustomObject to help you archive faster:

```
#import "NSUserDefaults+RMSaveCustomObject.h"

// ...
NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
[defaults rm_setCustomObject:user forKey:@"SAVED_DATA"];

```

To retrieve the custom object from NSUserDefaults:

```
user = [defaults rm_customObjectForKey:@"SAVED_DATA"];
```

To make a class copyable, just include below code into your class:

```
#import "NSObject+RMCopyable.h"
```

About
=====

The code to retrieve all attributes of a class is taken from http://stackoverflow.com/questions/754824/get-an-object-attributes-list-in-objective-c/13000074#13000074

Thanks Farthen and all user contributes to that thread!


License
=======

MIT License