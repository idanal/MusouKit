//
//  JSONEntity.m
//  
//
//  Created by danal on 7/3/15.
//  Copyright (c) 2015 danal. All rights reserved.
//

#import "MSJSONEntity.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error ARC support only
#endif

@implementation NSObject (JSONEntity)

/** Get all property names */
+ (NSArray *)getPropertyNames:(id)obj{
    return [self getPropertyNames:obj rootClass:@"NSObject"];
}

+ (NSArray *)getPropertyNames:(id)obj rootClass:(NSString *)rootClass{
    NSMutableArray *all = [NSMutableArray new];
    Class cls = [obj class];
    while (cls) {
        if ([NSStringFromClass(cls) isEqualToString:rootClass]) break;
        
        unsigned int n = 0;
        objc_property_t *ps = class_copyPropertyList(cls, &n);
        for (unsigned int i = 0; i < n; i++){
            objc_property_t p = ps[i];
            [all addObject:@(property_getName(p))];
        }
        free(ps);
        
        cls = class_getSuperclass(cls);
    }
    return all;

}

+ (instancetype)fromDict:(NSDictionary *)d{
    NSObject *o = [[self alloc] init];
    [o fromDict:d map:[o classMap]];
    return o;
}

+ (instancetype)fromJSON:(NSData *)json{
    NSObject *o = [[self alloc] init];
    [o fromDict:[NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:nil] map:[o classMap]];
    return o;
}

- (instancetype)fromDict:(NSDictionary *)d map:(NSDictionary *)map{
    [d enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
        @try {
            [self setValue:[self _entityOfValue:val key:key map:map] forKey:key];
        }
        @catch (NSException *exception) {
#ifdef DEBUG
            NSLog(@"%s %@", __func__, exception.description);
#endif
        }
    }];
    return self;
}

- (NSDictionary *)toDict{
    return [self _toBasicType];
}

- (NSData *)toJSON{
    return [NSJSONSerialization dataWithJSONObject:[self toDict] options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSString *)toJSONString{
    NSData *data = [self toJSON];
    return [self toJSONString:data];
}

- (NSString *)toJSONString:(NSData *)data{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)printObject{
    NSArray *keys = [NSObject getPropertyNames:self];
    for (NSString *key in keys) {
        NSLog(@"%@=%@",key,[self valueForKey:key]);
    }
}

#pragma mark - private methods

/** Convert a property to a NS-Type(NSString,NSNumber,NSDictionary,NSArray...) */
- (id)_toBasicType{
    @try {
        
        id self_ = self;
        if ([self_ isKindOfClass:[NSNumber class]]
            || [self_ isKindOfClass:[NSString class]]
            || [self_ isKindOfClass:[NSNull class]] ){
            
            return self_;
        }
        else if ([self_ isKindOfClass:[NSDictionary class]]){
            
            NSMutableDictionary *d = [NSMutableDictionary new];
            [(NSDictionary *)self_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [d setObject:obj == nil ? [NSNull null] : [obj _toBasicType] forKey:key];
            }];
            return d;
        }
        else if ([self_ isKindOfClass:[NSArray class]]){
            
            NSMutableArray *arr = [NSMutableArray new];
            for (id obj in (NSArray *)self_){
                [arr addObject:obj == nil ? [NSNull null] :[obj _toBasicType]];
            }
            return arr;
        }
        else {  //Object
            
            NSArray *keys = [NSObject getPropertyNames:self];
            NSMutableDictionary *d = [NSMutableDictionary new];
            for (NSString *key in keys){
                id obj = [self valueForKey:key];
                [d setObject:obj == nil ? [NSNull null] :[obj _toBasicType] forKey:key];
            }
            return d;
        }
        return self_;
    }
    @catch (NSException *exception) {
#ifdef DEBUG
        NSLog(@"%s %@", __func__, exception.description);
#endif
    }
}

/** Convert a basic type value to an entity */
- (id)_entityOfValue:(id)val key:(NSString *)key map:(NSDictionary *)map{
  
    if (val == nil
        || [val isKindOfClass:[NSNumber class]]
        || [val isKindOfClass:[NSString class]]
        || [val isKindOfClass:[NSNull class]] ){
        
        return val;
    }
    else if ([val isKindOfClass:[NSDictionary class]]){
        
        //Find the entity class that maped the key
        //The dictionary must map to an entity
        Class cls = [self _mapedClass:key map:map];
        id obj = [cls new];
        [obj fromDict:val map:map];
        return obj;
    }
    else if ([val isKindOfClass:[NSArray class]]){
        
        NSMutableArray *arr = [NSMutableArray new];
        [self setValue:arr forKey:key];
        for (id obj in (NSArray *)val){
            [arr addObject:[self _entityOfValue:obj key:key map:map]];
        }
        return arr;
    }
    else {  //Objects
        NSAssert(NO, @"Only basic types accepted");
    }
    return val;
}

/** Lookup the Class name which the key maped to */
- (Class)_mapedClass:(NSString *)key map:(NSDictionary *)map{
    if (map[key]){
        return NSClassFromString(map[key]);
    } else {
        NSString *name = key;
        NSRange range = [name rangeOfString:@"List"];
        if (range.length > 0 && range.location > 0){
            name = [name substringToIndex:range.location];
        }
        NSString *c  = [name substringToIndex:1];
        //return NSClassFromString([key capitalizedString]);
        return NSClassFromString([name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[c uppercaseString]]);
    }
}

- (NSDictionary *)classMap{
    return nil;
}

@end
