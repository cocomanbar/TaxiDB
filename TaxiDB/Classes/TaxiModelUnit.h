//
//  TaxiModelUnit.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaxiModelUnit : NSObject

#pragma mark - 操作对象方向相关

/// 检查是否遵守协议
BOOL modelUnitJoinProtocolForClass(Class cls);

/// 获取模型内参与数据库建设的字段名和字段类型
NSDictionary *modelUnitIvarNameForClass(Class cls);

/// 获取模型内参与数据库建设的字段名和(字段类型->转化到数据库类型)
NSDictionary *modelUnitIvarNameSetSqliteForClass(Class cls);

/// 获取模型内参与数据库建设的字段名
NSArray *modelUnitSetSqlitePropertiesForClass(Class cls);

/// 通过查询sql获取字典数组后，通过此方式转化为对应的模型数组
NSArray *modelUnitParseResultsForSqlSearch(NSArray <NSDictionary *>*maps, Class cls);

@end

NS_ASSUME_NONNULL_END
