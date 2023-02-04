//
//  NSObject+TaxiDB.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "NSObject+TaxiDB.h"
#import "TaxiField.h"

@implementation NSObject (TaxiDB)

@end

@implementation NSDictionary (TaxiDB)

- (NSInteger)taxi_integerForKey:(NSString *)aKey {
    id objc = [self objectForKey:aKey];
    if ([objc isKindOfClass:NSNumber.class]) {
        return [objc integerValue];
    } else if ([objc isKindOfClass:NSString.class]) {
        return [objc integerValue];
    }
    return 0;
}

- (double)taxi_doubleForKey:(NSString *)aKey {
    id objc = [self objectForKey:aKey];
    if ([objc isKindOfClass:NSNumber.class]) {
        return [objc doubleValue];
    } else if ([objc isKindOfClass:NSString.class]) {
        return [objc doubleValue];
    }
    return 0;
}

- (nullable NSString *)taxi_stringForKey:(NSString *)aKey {
    id objc = [self objectForKey:aKey];
    if ([objc isKindOfClass:NSString.class]) {
        return objc;
    }
    return nil;
}

- (nullable NSData *)taxi_dataForKey:(NSString *)aKey {
    id objc = [self objectForKey:aKey];
    if ([objc isKindOfClass:NSData.class]) {
        return objc;
    }
    return nil;
}

- (nullable NSArray *)taxi_arrayForKey:(NSString *)aKey {
    id objc = [self objectForKey:aKey];
    if ([objc isKindOfClass:NSArray.class]) {
        return objc;
    }
    return nil;
}

- (nullable NSDictionary *)taxi_dictionaryForKey:(NSString *)aKey {
    id objc = [self objectForKey:aKey];
    if ([objc isKindOfClass:NSDictionary.class]) {
        return objc;
    }
    return nil;
}

- (nullable NSString *)taxi_JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:NULL];
    if (!data || data.length == 0) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (nullable NSDictionary *)taxi_dictionaryWithJSONString:(NSString * _Nullable)JSONString {
    
    NSDictionary *object;
    if (!JSONString || JSONString.length == 0) {
        return object;
    }
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    object = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if ([object isKindOfClass:NSDictionary.class]) {
        return object;
    }
    return nil;
}

@end

@implementation NSMutableDictionary (TaxiDB)

- (void)taxi_setObject:(id)anObject forField:(TaxiField *)aField {
    
    [self taxi_setObject:anObject forKey:aField.name];
}

- (void)taxi_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}


@end

@implementation NSString (TaxiDB)

+ (BOOL)isEmpty:(NSString *)aString {
    if ([aString isKindOfClass:NSString.class] && aString.length > 0) {
        return false;
    }
    return true;
}

@end

@implementation NSMutableArray (TaxiDB)

- (void)taxi_addObject:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

- (void)taxi_addObjectsFromArray:(NSArray *)otherArray {
    if ([otherArray isKindOfClass:NSArray.class]) {
        [self addObjectsFromArray:otherArray];
    }
}

@end
