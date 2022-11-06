//
//  TaxiDB+ModelPublic.m
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiDB+ModelPublic.h"
#import "TaxiDB+Sqlite.h"
#import "TaxiDBModelProtocol.h"
#import "TaxiDBUpdateProtocol.h"

@implementation TaxiDB (ModelPublic)

#pragma mark - 表操作相关

/// 检查是否存在该表
- (BOOL)existTable:(Class)cls{
    modelUnitJoinProtocolForClass(cls);
    NSString *tableName = tableUnitTableNameForClass(cls);
    NSString *sql = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    NSMutableArray *resultArray = [self querySql:sql];
    return resultArray.count > 0;
}

/// 创建表信息
- (BOOL)createTable:(Class)cls{
    if ([self existTable:cls]) {
        return YES;
    }
    /// 1.create table if not exists 表名(字段1 字段1类型(约束),字段2 字段2类型(约束),字段3 字段3类型(约束),.....,primary(字段))
    NSString *tableName = tableUnitTableNameForClass(cls);
    NSString *primaryKey = [cls taxidb_primaryKey];
    /// 2.获取一个模型里面所有的字段名字，以及类型
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@))",tableName, tableUnitModelSqlForClass(cls), primaryKey];
    /// 3.执行(返回是否创建成功)
    BOOL result = [self dealSql:sql];
    /// 4.每创建好一个表都将其信息加入根表中备份
    if (result) {
        /// 4.1查询是否有相同的表名，插入信息
        NSArray *result = [self querySql:rootTableSearchSql(tableName)];
        if (result && result.count > 0) {
            [self dealSql:rootTableDeleteSql(tableName)];
        }
        [self dealSql:rootTableInsertSql(tableName, NSStringFromClass(cls), @(kTaxiTableDefaultVersion).stringValue)];
    }
    return result;
}

/// 清空一个表数据
- (BOOL)cleanTable:(Class)cls{
    if (![self existTable:cls]) {
        return YES;
    }
    NSString *tableName = tableUnitTableNameForClass(cls);
    NSString *sql = [NSString stringWithFormat:@"delete from %@", tableName];
    return [self dealSql:sql];
}

/// 表需要更新[一般使用在创建完表后检查一次]
- (void)updateTable:(Class)cls{
    if (tableUnitNeedUpdateForClass(cls)) {
#ifdef DEBUG
        NSLog(@"[TaxiDB]：`%@` 表需要更新", NSStringFromClass(cls));
#endif
        if (tableUnitUpdateForClass(cls)) {
#ifdef DEBUG
            NSLog(@"[TaxiDB]：`%@` 表更新成功", NSStringFromClass(cls));
#endif
        }
    }
}

#pragma mark - 模型操作

/**
 *  写入一组全新数据
 *
 *  1.组内数据类型一致, 不一致的将会被剔除
 *  2.遇到相同主键模型不会更新
 */
- (BOOL)insertModels:(NSArray <id>*)models{
    
    if (!models || !models.count) {
        return NO;
    }
    /// 获取模型
    Class cls = [models.firstObject class];
    /// 检查表
    [self createOrUpdateTableIfNeeded:cls];
    /// 表名
    NSString *tableName = tableUnitTableNameForClass(cls);
    /// 获取表中所有的字段（下面的方法获取的是字典，我们取其键）
    NSArray *columnNames = tableUnitSqlitePropertiesForClass(cls);
    
    void(^PoolBlock)(void) = ^{
        
        for (id model in models) {
            
            if (![model isKindOfClass:cls]) {
                continue;
            }
            /// 存储模型理应插入数据的字段的所有值，但是必须要是有效值!
            NSMutableArray *columnNameValues = [NSMutableArray array];
            /// 有效值对应的字段名，和上面数据一一对应，避免插入时出乱
            NSMutableArray *tempcolumnNames = [NSMutableArray array];
            
            for (NSString *columnName in columnNames) {
                id columnNameValue = [model valueForKeyPath:columnName];
                /// 判断类型是不是数组或者字典, 字典/数组 -> NSData ->NSString
                if ([columnNameValue isKindOfClass:[NSArray class]] || [columnNameValue isKindOfClass:[NSDictionary class]]) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:columnNameValue options:NSJSONWritingPrettyPrinted error:nil];
                    columnNameValue = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
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

/**
 *  更新一组数据
 *
 *  1.组内数据类型一致, 不一致的将会被剔除
 *  2.无对应主键模型的更新时,不会直接插入新数据
 */
- (BOOL)updateModels:(NSArray <id>*)models{
    if (!models || !models.count) {
        return YES;
    }
    /// 获取模型
    Class cls = [models.firstObject class];
    /// 检查表
    [self createOrUpdateTableIfNeeded:cls];
    /// 表名
    NSString *tableName = tableUnitTableNameForClass(cls);
    /// 主键字段
    NSString *primaryKey = [cls taxidb_primaryKey];
    /// 获取表中所有的字段（下面的方法获取的是字典，我们取其键）
    NSArray *columnNames = tableUnitSqlitePropertiesForClass(cls);
    
    void(^PoolBlock)(void) = ^{
        
        for (id model in models) {
            
            if (![model isKindOfClass:cls]) {
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
                if ([columnNameValue isKindOfClass:[NSArray class]] || [columnNameValue isKindOfClass:[NSDictionary class]]) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:columnNameValue options:NSJSONWritingPrettyPrinted error:nil];
                    columnNameValue = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
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
                execSql = [NSString stringWithFormat:@"update %@ set %@ where %@ = %@;",tableName, [setValueArray componentsJoinedByString:@","], primaryKey, primaryKeyValue];
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

/**
 *  无条件插入或更新数据
 *
 *  1.不确定数据是否存在时，有主键数据更新，无主键数据插入
 */
- (BOOL)initialModels:(NSArray <id>*)models{
    if (!models || !models.count) {
        return YES;
    }
    /// 获取模型
    Class cls = [models.firstObject class];
    /// 检查表
    [self createOrUpdateTableIfNeeded:cls];
    /// 表名
    NSString *tableName = tableUnitTableNameForClass(cls);
    /// 主键字段
    NSString *primaryKey = [cls taxidb_primaryKey];
    /// 获取表中所有的字段（下面的方法获取的是字典，我们取其键）
    NSArray *columnNames = tableUnitSqlitePropertiesForClass(cls);
    
    void(^PoolBlock)(void) = ^{
        
        for (id model in models) {
            
            if (![model isKindOfClass:cls]) {
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
                if ([columnNameValue isKindOfClass:[NSArray class]] || [columnNameValue isKindOfClass:[NSDictionary class]]) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:columnNameValue options:NSJSONWritingPrettyPrinted error:nil];
                    columnNameValue = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
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

/**
 *  删除一组数据, 组内数据类型一致, 不一致的将会被剔除
 */
- (BOOL)deleteModels:(NSArray <id>*)models{
    
    if (!models || !models.count) {
        return YES;
    }
    /// 获取模型
    Class cls = [models.firstObject class];
    /// 表名
    NSString *tableName = tableUnitTableNameForClass(cls);
    /// 主键字段
    NSString *primaryKey = [cls taxidb_primaryKey];
    /// 主键类型
    NSString *primaryType = tableUnitPrimaryTypeForClass(cls);
    
    for (id model in models) {
        if (![model isKindOfClass:cls]) {
            continue;
        }
        /// 模型里面主键的值
        id primaryKeyValue = [model valueForKeyPath:primaryKey];
        NSString *deleteSql = nil;
        if ([primaryType isEqualToString:@"NSString"]) {
            deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = \"%@\";",tableName, primaryKey, primaryKeyValue];
        }else{
            deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = %@;",tableName, primaryKey, primaryKeyValue];
        }
        [self dealSql:deleteSql];
    }
    
    return YES;
}

/**
 *  根据条件删除一个数据
 */
- (BOOL)deleteModel:(id)model where:(NSString *)condition{
    
    Class cls = [model class];
    /// 获取表名
    NSString *tableName = tableUnitTableNameForClass(cls);
    /// 条件小于0直接返回
    if (!condition || !condition.length) {
        return NO;
    }
    /// 组建删除表的语句
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@;", tableName, condition];
    
    return [self dealSql:deleteSql];
}

/**
 *  查询表数据
 */
- (NSArray *)queryModels:(Class)cls{
    /// 获取表名
    NSString *tableName = tableUnitTableNameForClass(cls);
    /// 组合查询语句
    NSString *querySql = [NSString stringWithFormat:@"select * from %@",tableName];
    /// 2.执行查询 key value
    /// 模型的属性名称 和 属性值
    NSArray <NSDictionary *>*results = [self querySql:querySql];
    /// 3.处理查询结果集 -> 模型数组
    NSArray *models = modelUnitParseResultsForSqlSearch(results, cls);
    
    return models;
}

/**
 *  根据条件查询表数据
 */
- (NSArray *)queryModels:(Class)cls where:(NSString *)condition{
    /// 获取表名
    NSString *tableName = tableUnitTableNameForClass(cls);
    /// 组合查询语句
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where %@;",tableName,condition];
    /// 执行查询 key value
    /// 模型的属性名称 和 属性值
    NSArray <NSDictionary *>*results = [self querySql:querySql];
    /// 3.处理查询结果集 -> 模型数组
    NSArray *models = modelUnitParseResultsForSqlSearch(results, cls);
    
    return models;
}

#pragma mark - Private

- (void)createOrUpdateTableIfNeeded:(Class)cls{
    
    /// 检查表是否存在
    if (![self existTable:cls]) {
        [self createTable:cls];
    }
    
    if (TAXIDB.autoUpdateTable == false) {
        return;
    }
    
    /// 检查表更新
    [self updateTable:cls];
}

@end
