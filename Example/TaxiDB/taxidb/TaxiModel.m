//
//  TaxiModel.m
//  TaxiDB_Example
//
//  Created by tanxl on 2022/11/6.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "TaxiModel.h"

@implementation TaxiModel

/// 当前表的版本初始化值，如果表发生变化，该值加1，用于与记录对比
+ (NSUInteger)taxidb_version {
    return kTaxiTableDefaultVersion;
}

/// 自定义表名, 默认模型名字
+ (NSString * _Nonnull)taxidb_sqliteTableName {
    return NSStringFromClass(self);
}

/// 必须有主键
/// 需包含在`taxidb_allowedJoinSqliteKeyFromPreviousVersion:`里
+ (NSString * _Nonnull)taxidb_primaryKey {
    NSAssert(![self respondsToSelector:@selector(testId)], @"主键定义了就不要更改了");
    return @"testId";
}

/// 参与数据库的字段
/// 丢弃或替换的字段在模型里请保持声明，避免升级时数据丢失
+ (NSArray *)taxidb_allowedJoinSqliteKeyFromPreviousVersion:(NSInteger)previousVersion {
    
    return @[@"name",
             @"address",
             @"testId",
             @"count",
             @"links_arr",
             @"links_arr_m",
             @"links_map",
             @"links_map_m"
            ];
}

/// 更新字段: 新字段名字 到 旧字段名字 的映射表
/// key代表新字段
/// value代表旧字段
//+ (NSDictionary *)taxidb_replacedSqliteKeyFromPreviousVersion:(NSInteger)previousVersion;

@end
