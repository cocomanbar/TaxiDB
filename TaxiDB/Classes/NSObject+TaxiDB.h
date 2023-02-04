//
//  NSObject+TaxiDB.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TaxiField;

@interface NSObject (TaxiDB)

@end

@interface NSDictionary (TaxiDB)

- (NSInteger)taxi_integerForKey:(NSString *)aKey;

- (double)taxi_doubleForKey:(NSString *)aKey;

- (nullable NSString *)taxi_stringForKey:(NSString *)aKey;

- (nullable NSData *)taxi_dataForKey:(NSString *)aKey;

- (nullable NSArray *)taxi_arrayForKey:(NSString *)aKey;

- (nullable NSDictionary *)taxi_dictionaryForKey:(NSString *)aKey;


- (nullable NSString *)taxi_JSONString;

+ (nullable NSDictionary *)taxi_dictionaryWithJSONString:(NSString * _Nullable)JSONString;

@end

@interface NSMutableDictionary (TaxiDB)

- (void)taxi_setObject:(id)anObject forField:(TaxiField *)aField;

- (void)taxi_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end

@interface NSString (TaxiDB)

+ (BOOL)isEmpty:(NSString *)aString;

@end

@interface NSMutableArray (TaxiDB)

- (void)taxi_addObject:(id)anObject;

- (void)taxi_addObjectsFromArray:(NSArray *)otherArray;

@end

NS_ASSUME_NONNULL_END
