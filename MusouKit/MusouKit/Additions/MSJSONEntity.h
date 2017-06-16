//
//  JSONEntity.h
//  
//  QQ:290994669 
//  Created by danal on 7/3/15.
//  Copyright (c) 2015 danal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSONEntity)

/** Get all property names */
+ (NSArray *)getPropertyNames:(id)obj;
+ (NSArray *)getPropertyNames:(id)obj rootClass:(NSString *)rootClass;

/**
 * Convert json to an entity
 * @param json Json data
 */
+ (instancetype)fromJSON:(NSData *)json;

/**
 * Convert a dictionary to an entity
 * @param d Dictionary data
 */
+ (instancetype)fromDict:(NSDictionary *)d;

/**
 * Json Entity class map
 * Used to map a key to a Class.
 * Override this method to supply a class map
 *              e.g. @{@"a":@"AAA",@"list":@"BBB"},
 *              'a' is a key in the dictionary, and 'AAA' is the class name;
 *              'list' is an array, and 'BBB' is the class name of the element in the array
 */
- (NSDictionary *)jeClassMap;

/**
 * Convert to dictionary
 */
- (NSDictionary *)toDict;

/**
 * Convert to json
 */
- (NSData *)toJSON;
- (NSString *)toJSONString;
- (NSString *)toJSONString:(NSData *)data;



@end
