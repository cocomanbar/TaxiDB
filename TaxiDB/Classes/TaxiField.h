//
//  TaxiField.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *TaxiFieldType;

static TaxiFieldType TaxiFieldTypeInteger = @"integer";
static TaxiFieldType TaxiFieldTypeDouble = @"double";
static TaxiFieldType TaxiFieldTypeText = @"text";
static TaxiFieldType TaxiFieldTypeBlob = @"blob";

@interface TaxiField : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) TaxiFieldType fieldType;

/// 数据库`sqlite3`只支持设置一个主键，且不能为Null
@property (nonatomic, assign) BOOL primaryKey;

/// 当字段类型 `integer` 且设置主键时生效
@property (nonatomic, assign) BOOL autoincrement;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString * _Nullable)name fieldType:(TaxiFieldType _Nullable)fieldType;
+ (instancetype)fieldWithName:(NSString * _Nullable)name fieldType:(TaxiFieldType _Nullable)fieldType;

@end

NS_ASSUME_NONNULL_END
