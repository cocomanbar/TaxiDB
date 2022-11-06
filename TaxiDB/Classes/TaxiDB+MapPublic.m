//
//  TaxiDB+MapPublic.m
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiDB+MapPublic.h"
#import "TaxiDB+Sqlite.h"

@implementation TaxiDB (MapPublic)

#pragma mark -

- (BOOL)existTable_:(NSString *)tableName{
    
    NSString *sql = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    NSMutableArray *resultArray = [self querySql:sql];
    return resultArray.count > 0;
}

- (BOOL)cleanTable_:(NSString *)tableName{
    if (![self existTable_:tableName]) {
        return YES;
    }
    NSString *sql = [NSString stringWithFormat:@"delete from %@", tableName];
    return [self dealSql:sql];
}

- (BOOL)createTable_:(NSString *)tableName modelMap_:(NSDictionary *)modelMap primaryKey_:(NSString *)primaryKey{
    if ([self existTable_:tableName]) {
        return YES;
    }
    /// 1.create table if not exists 表名(字段1 字段1类型(约束),字段2 字段2类型(约束),字段3 字段3类型(约束),.....,primary(字段))
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@))",
                     tableName,
                     mapUnitModelSqlForClass_(modelMap, primaryKey),
                     primaryKey];
    /// 3.执行(返回是否创建成功)
    return [self dealSql:sql];
}

#pragma mark -

- (BOOL)insertModels_:(NSArray <NSDictionary *>*)models tableName_:(NSString *)tableName primaryKey_:(NSString *)primaryKey{
    if (models.count == 0 || ![self existTable_:tableName] || !primaryKey.length) {
        return NO;
    }
    /// 表中所有存储的字段
    NSArray *columnNames = mapUnitTableSqlitePropertiesForClass_(tableName);
    
    void(^PoolBlock)(void) = ^{
        
        for (NSDictionary *model in models) {
            
            if (![model isKindOfClass:NSDictionary.class]) {
                continue;
            }
            if (![model objectForKey:primaryKey]) {
                continue;
            }
            
            /// 存储模型理应插入数据的字段的所有值，但是必须要是有效值!
            NSMutableArray *columnNameValues = [NSMutableArray array];
            /// 有效值对应的字段名，和上面数据一一对应，避免插入时出乱
            NSMutableArray *tempcolumnNames = [NSMutableArray array];
            
            for (NSString *columnName in columnNames) {
                id columnNameValue = [model objectForKey:columnName];
                /// 判断类型是不是NSString
                if (![columnNameValue isKindOfClass:[NSString class]]) {
                    columnNameValue = nil;
                }
                if (!columnNameValue) {
                    continue;
                }
                [tempcolumnNames addObject:columnName];
                [columnNameValues addObject:columnNameValue];
            }
            /// 有效值一个也没有的异常情况，该模型不缓存
            if (columnNameValues.count == 0) {
                continue;
            }
            
            /// 进行记录的插入操作
            /// 提示这里 insert into %@(%@) values('%@');，其中的value 要是： 'value1','value2','value2'这样的格式
            NSString *execSql = [NSString stringWithFormat:@"insert into %@(%@) values('%@');",tableName, [tempcolumnNames componentsJoinedByString:@","], [columnNameValues componentsJoinedByString:@"','"]];
            /// 执行更新或插入
            [self dealSql:execSql];
        }
    };
    
    @autoreleasepool {
        PoolBlock();
    }
    
    return YES;
}

- (BOOL)updateModels_:(NSArray <NSDictionary *>*)models tableName_:(NSString *)tableName primaryKey_:(NSString *)primaryKey{
    if (models.count == 0 || ![self existTable_:tableName] || !primaryKey.length) {
        return NO;
    }
    /// 表中所有存储的字段
    NSArray *columnNames = mapUnitTableSqlitePropertiesForClass_(tableName);
    
    void(^PoolBlock)(void) = ^{
        
        for (NSDictionary *model in models) {
            
            if (![model isKindOfClass:NSDictionary.class]) {
                continue;
            }
            if (![model objectForKey:primaryKey]) {
                continue;
            }
            
            id primaryKeyValue = [model objectForKey:primaryKey];
            /// 创建sql语句
            NSString *checkPrimaryKeySql = [NSString stringWithFormat:@"select * from %@ where %@ = \"%@\";",tableName, primaryKey, primaryKeyValue];
            
            /// 存储模型理应插入数据的字段的所有值，但是必须要是有效值!
            NSMutableArray *columnNameValues = [NSMutableArray array];
            /// 有效值对应的字段名，和上面数据一一对应，避免插入时出乱
            NSMutableArray *tempcolumnNames = [NSMutableArray array];
            
            for (NSString *columnName in columnNames) {
                id columnNameValue = [model valueForKeyPath:columnName];
                /// 判断类型是不是NSString
                if (![columnNameValue isKindOfClass:[NSString class]]) {
                    columnNameValue = nil;
                }
                if (!columnNameValue) {
                    continue;
                }
                [tempcolumnNames addObject:columnName];
                [columnNameValues addObject:columnNameValue];
            }
            /// 有效值一个也没有的异常情况，该模型不更新
            if (columnNameValues.count == 0) {
                continue;
            }
            
            /// 把字段和值拼接生成  字段 = 值   字符的数组
            NSInteger count = tempcolumnNames.count;
            NSMutableArray *setValueArray = [NSMutableArray array];
            for (int i = 0; i<count; i++) {
                
                NSString *name = tempcolumnNames[i];
                id value = columnNameValues[i];
                NSString *setStr = [NSString stringWithFormat:@"%@ = '%@'",name,value];
                [setValueArray addObject:setStr];
            }
            
            NSString *execSql = nil;
            /// update 表名 set 字段1=值 字段2=值.... where 主键名 = 对应的主键值;"
            /// 查询的结果大于0说明表中有这条数据，进行数据更新
            /// 获取 更新的 sql 语句
            if ([self querySql:checkPrimaryKeySql].count > 0) {
                execSql = [NSString stringWithFormat:@"update %@ set %@ where %@ = \"%@\";",tableName, [setValueArray componentsJoinedByString:@","], primaryKey, primaryKeyValue];
            }
            /// 查询不到记录放弃更新
            if (!execSql) {
                continue;
            }
            /// 执行更新或插入
            [self dealSql:execSql];
        }
    };
    
    @autoreleasepool {
        PoolBlock();
    }
    
    return YES;
}

- (BOOL)initialModels_:(NSArray <NSDictionary *>*)models tableName_:(NSString *)tableName primaryKey_:(NSString *)primaryKey{
    if (models.count == 0 || ![self existTable_:tableName] || !primaryKey.length) {
        return NO;
    }
    /// 表中所有存储的字段
    NSArray *columnNames = mapUnitTableSqlitePropertiesForClass_(tableName);
    
    void(^PoolBlock)(void) = ^{
        
        for (NSDictionary *model in models) {
            
            if (![model isKindOfClass:NSDictionary.class]) {
                continue;
            }
            if (![model objectForKey:primaryKey]) {
                continue;
            }
            
            id primaryKeyValue = [model valueForKeyPath:primaryKey];
            /// 创建sql语句
            NSString *checkPrimaryKeySql = [NSString stringWithFormat:@"select * from %@ where %@ = %@;",tableName, primaryKey, primaryKeyValue];
            
            /// 存储模型理应插入数据的字段的所有值，但是必须要是有效值!
            NSMutableArray *columnNameValues = [NSMutableArray array];
            /// 有效值对应的字段名，和上面数据一一对应，避免插入时出乱
            NSMutableArray *tempcolumnNames = [NSMutableArray array];
            
            for (NSString *columnName in columnNames) {
                id columnNameValue = [model valueForKeyPath:columnName];
                /// 判断类型是不是数组或者字典, 字典/数组 -> NSData ->NSString
                if (![columnNameValue isKindOfClass:[NSString class]]) {
                    columnNameValue = nil;
                }
                if (!columnNameValue) {
                    continue;
                }
                [tempcolumnNames addObject:columnName];
                [columnNameValues addObject:columnNameValue];
            }
            /// 有效值一个也没有的异常情况，该模型不更新
            if (columnNameValues.count == 0) {
                continue;
            }
            
            /// 把字段和值拼接生成  字段 = 值   字符的数组
            NSInteger count = tempcolumnNames.count;
            NSMutableArray *setValueArray = [NSMutableArray array];
            for (int i = 0; i<count; i++) {
                
                NSString *name = tempcolumnNames[i];
                id value = columnNameValues[i];
                NSString *setStr = [NSString stringWithFormat:@"%@ = '%@'",name,value];
                [setValueArray addObject:setStr];
            }
            
            NSString *execSql = @"";
            
            if ([self querySql:checkPrimaryKeySql].count > 0) {
                
                /// update 表名 set 字段1=值 字段2=值.... where 主键名 = 对应的主键值;"
                /// 查询的结果大于0说明表中有这条数据，进行数据更新
                /// 获取 更新的 sql 语句
                execSql = [NSString stringWithFormat:@"update %@ set %@ where %@ = %@;",tableName, [setValueArray componentsJoinedByString:@","], primaryKey, primaryKeyValue];
            }else{
                
                /// 不存在数据，进行记录的插入操作
                /// 提示这里 insert into %@(%@) values('%@');，其中的value 要是： 'value1','value2','value2'这样的格式
                execSql = [NSString stringWithFormat:@"insert into %@(%@) values('%@');",tableName, [tempcolumnNames componentsJoinedByString:@","], [columnNameValues componentsJoinedByString:@"','"]];
            }
            
            /// 执行更新或插入
            [self dealSql:execSql];
        }
    };
    
    @autoreleasepool {
        PoolBlock();
    }
    return YES;
}

- (BOOL)deleteModels_:(NSArray <NSDictionary *>*)models tableName_:(NSString *)tableName primaryKey_:(NSString *)primaryKey{
    if (models.count == 0 || ![self existTable_:tableName] || !primaryKey.length) {
        return NO;
    }
    for (NSDictionary *model in models) {
        if (![model isKindOfClass:NSDictionary.class]) {
            continue;
        }
        /// 模型里面主键的值
        id primaryKeyValue = [model objectForKey:primaryKey];
        if (!primaryKeyValue) {
            continue;
        }
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = \"%@\";",tableName, primaryKey, primaryKeyValue];
        [self dealSql:deleteSql];
    }
    return YES;
}

- (BOOL)deleteModel_:(NSDictionary *)model tableName_:(NSString *)tableName where_:(NSString *)condition{
    /// 条件小于0直接返回
    if (!condition || !condition.length) {
        return NO;
    }
    /// 组建删除表的语句
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@;", tableName, condition];
    return [self dealSql:deleteSql];
}

- (NSArray <NSDictionary *>*)queryModels_:(NSString *)tableName{
    NSString *querySql = [NSString stringWithFormat:@"select * from %@",tableName];
    NSArray <NSDictionary *>*results = [self querySql:querySql];
    return results;
}

- (NSArray <NSDictionary *>*)queryModels_:(NSString *)tableName where_:(NSString *)condition{
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where %@;",tableName,condition];
    NSArray <NSDictionary *>*results = [self querySql:querySql];
    return results;
}

@end
