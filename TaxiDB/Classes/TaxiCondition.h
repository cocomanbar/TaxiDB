//
//  TaxiCondition.h
//  TaxiDB
//
//  Created by tanxl on 2023/2/1.
//

#import <Foundation/Foundation.h>
#import "TaxiField.h"
#import "TaxiUtilities.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaxiTask){
    TaxiTaskSelect = 0,
    TaxiTaskUpdate,
    TaxiTaskDelete,
    TaxiTaskInsert,
    TaxiTaskReplace,
};

@class TaxiStatement;

/**
 *  TODO..
 */
@interface TaxiCondition : NSObject

// where
- (TaxiCondition * (^)(TaxiField *field))whereField;

- (TaxiCondition * (^)(id value))equalTo;
- (TaxiCondition * (^)(id value))greaterThan;
- (TaxiCondition * (^)(id value))greaterThanOrEqualTo;
- (TaxiCondition * (^)(id value))lessThan;
- (TaxiCondition * (^)(id value))lessThanOrEqualTo;

// update
- (TaxiCondition * (^)(TaxiField *field))updateField;
- (TaxiCondition * (^)(NSArray <TaxiField *>*fields))updateFields;

// replace
- (TaxiCondition * (^)(TaxiField *field))replaceField;
- (TaxiCondition * (^)(NSArray <TaxiField *>*fields))replaceFields;

// insert
- (TaxiCondition * (^)(TaxiField *field))insertField;
- (TaxiCondition * (^)(NSArray <TaxiField *>*fields))insertFields;

// order
- (TaxiCondition * (^)(TaxiField *field))orderField;

// limit
- (TaxiCondition * (^)(NSInteger count))limitCount;
- (TaxiCondition * (^)(NSInteger count, NSInteger offset))limitOffset;
- (TaxiCondition * (^)(NSInteger location, NSInteger length))limitRange;

- (TaxiCondition * (^)(void))byASC;
- (TaxiCondition * (^)(void))byDESC;

- (TaxiCondition * (^)(void))byOR;


// 用于预编译sql语句时，stmt绑定的顺序值
- (TaxiCondition * (^)(id value))withValue;
- (TaxiCondition * (^)(NSArray *values))withValues;

// 如果你使用此接口写sql语句，那么
// 类似其他的语句 where update insert 将不会考虑进来，因此这是一个完整的可带 ? 的sql语句
// 例如:
// SELECT * FROM Orders WHERE Id = 6 ORDER BY Price DESC
// SELECT * FROM Orders WHERE Id = ? ORDER BY Price DESC 其中 ？的值需要通过 `withValue` or `withValues` 补充
- (TaxiCondition * (^)(NSString *sql))writeSql;

@end

#define taxi_equalTo(...)                equalTo(TaxiBoxValue((__VA_ARGS__)))

#define taxi_greaterThan(...)            greaterThan(TaxiBoxValue((__VA_ARGS__)))
#define taxi_greaterThanOrEqualTo(...)   greaterThanOrEqualTo(TaxiBoxValue((__VA_ARGS__)))

#define taxi_lessThan(...)               lessThan(TaxiBoxValue((__VA_ARGS__)))
#define taxi_lessThanOrEqualTo(...)      lessThanOrEqualTo(TaxiBoxValue((__VA_ARGS__)))

#define taxi_withValue(...)              withValue(TaxiBoxValue((__VA_ARGS__)))


NS_ASSUME_NONNULL_END
