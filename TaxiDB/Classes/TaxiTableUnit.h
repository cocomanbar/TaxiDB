//
//  TaxiTableUnit.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaxiTableUnit : NSObject

/// 获取表名
NSString *tableUnitTableNameForClass(Class cls);

/// 获取临时表名
NSString *tableUnitTempTableNameForClass(Class cls);

/// 将获取到参与数据库建设的字段和对应数据库类型的数据拼接成对应的sql语句
NSString *tableUnitModelSqlForClass(Class cls);

/// 获取表内所有字段名, 将于上面的方法对比判断表是否需要更新[modelUnitSetSqlitePropertiesForClass]
NSArray *tableUnitSqlitePropertiesForClass(Class cls);

/// 获取该表主键表类型，用于查询或删除sql拼接
NSString *tableUnitPrimaryTypeForClass(Class cls);

/// 判断表是否需要更新（模型参与数据库建设字段与数据库获取表的字段的比较是否有变化）
BOOL tableUnitNeedUpdateForClass(Class cls);

/// 表更新【处理在初始化时或升级时】
BOOL tableUnitUpdateForClass(Class cls);


@end

NS_ASSUME_NONNULL_END
