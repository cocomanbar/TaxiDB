//
//  TaxiTableUnit.m
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiTableUnit.h"
#import "TaxiDB+Sqlite.h"
#import "TaxiDBModelProtocol.h"
#import "TaxiDBUpdateProtocol.h"

@implementation TaxiTableUnit

/// 获取表名
FOUNDATION_EXTERN_INLINE NSString *tableUnitTableNameForClass(Class cls){
    modelUnitJoinProtocolForClass(cls);
    if ([cls performSelector:@selector(taxidb_sqliteTableName)]) {
        return [cls taxidb_sqliteTableName];
    }
    return NSStringFromClass(cls);
}

/// 获取临时表名
FOUNDATION_EXTERN_INLINE NSString *tableUnitTempTableNameForClass(Class cls){
    modelUnitJoinProtocolForClass(cls);
    if ([cls performSelector:@selector(taxidb_sqliteTableName)]) {
        return [NSString stringWithFormat:@"temp_%@",[cls taxidb_sqliteTableName]];
    }
    return [NSString stringWithFormat:@"temp_%@", NSStringFromClass(cls)];
}

/// 将获取到参与数据库建设的字段和对应数据库类型的数据拼接成对应的sql语句，加上联合主键`id`
FOUNDATION_EXTERN_INLINE NSString *tableUnitModelSqlForClass(Class cls){
    NSDictionary *dict = modelUnitIvarNameSetSqliteForClass(cls);
    NSMutableArray *result = [NSMutableArray array];
    // 主键
    NSString *primaryKey = [cls taxidb_primaryKey];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:primaryKey]) {
            [result addObject:[NSString stringWithFormat:@"%@ %@ not null",key,obj]];
        }else{
            [result addObject:[NSString stringWithFormat:@"%@ %@ default null",key,obj]];
        }
    }];
    return [result componentsJoinedByString:@","];
}

/// 获取表内所有字段名, 将于上面的方法对比判断表是否需要更新[modelUnitSetSqlitePropertiesForClass]
FOUNDATION_EXTERN_INLINE NSArray *tableUnitSqlitePropertiesForClass(Class cls){
    modelUnitJoinProtocolForClass(cls);
    /// 1.获取表名
    NSString *tableName = tableUnitTableNameForClass(cls);
    
    /// 2.获取通过查询数据库中所有的表的来获取相应的模型对应表的 sql 语句
    NSString *querySql = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    
    /// 3.查询模型的sql语句
    NSMutableDictionary *resultDic = [TAXIDB querySql:querySql].firstObject;
    /**
      resultDic={
      sql = "CREATE TABLE Student(studentName text,studentNumber integer,studentAge integer,studentScore real, primary key(studentNumber))";
      }
     */
    
    /// 4、根据sql键取出创建模型的sql语句
    /**
       CREATE TABLE Student(studentName text,studentNumber integer,studentAge integer,studentScore real, primary key(studentNumber))
     */
    /// 大写变小写没必要
    NSString *sqlString = resultDic[@"sql"];
    /// 过滤 \"
    sqlString = [sqlString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    /// 过滤 \t
    sqlString = [sqlString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    /// 过滤 \n
    sqlString = [sqlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if (sqlString.length == 0) {
        return nil;
    }
    
    /// 4.1、分割 sqlString 语句取出相应的字段名
    /// <1>、根据 `(` 取出 `studentName text,studentNumber integer,studentAge integer,studentScore real, primary key`
    NSString *nameTypeStr = [sqlString componentsSeparatedByString:@"("][1];
    /// <2>、再利用 `,` 分割<1>中的字符串,变成一个数组
    /**
       studentName text
       studentNumber integer
       studentAge integer
       studentScore real
       primary key
     */
    NSArray *nameTypeArray = [nameTypeStr componentsSeparatedByString:@","];
    
    /// 存放字段名的数组
    NSMutableArray *namesArray = [NSMutableArray array];
    
    for (NSString *nameType in nameTypeArray) {
        
        /// 如果包含 primary 跳过 ，因为它不是字段名
        if ([nameType containsString:@"primary"]) {
            continue;
        }
        
        /// 去除首尾空格
        NSString *nameType2 = [nameType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        /// 取出类型名字
        NSString *name = [nameType2 componentsSeparatedByString:@" "].firstObject;
        /// 放进数组
        [namesArray addObject:name];
    }
    
    /// 5.字段排序
    /// 不可变的数组，不需要重新赋值，排序后的数组就是变化后的数组
    [namesArray sortUsingComparator:^NSComparisonResult(NSString *obj1,NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    return namesArray;
}


/// 获取该表主键表类型，用于查询或删除sql拼接
NSString *tableUnitPrimaryTypeForClass(Class cls){
    modelUnitJoinProtocolForClass(cls);
    NSDictionary *dict = modelUnitIvarNameForClass(cls);
    NSString *primaryKey = [cls taxidb_primaryKey];
    __block NSString *type = nil;
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:primaryKey]) {
            type = obj;
            *stop = YES;
        }
    }];
    return type;
}

/// 判断表是否需要更新（模型参与数据库建设字段与数据库获取表的字段的比较是否有变化）
FOUNDATION_EXTERN_INLINE BOOL tableUnitNeedUpdateForClass(Class <TaxiDBModelProtocol>cls){
    
    /// 1.优先比较账目上的版本
    NSInteger modelVersion = [cls taxidb_version];
    NSInteger tableVersion = rootTableTableVersionFromCls(cls);
    if (modelVersion != tableVersion) {
        return YES;
    }
    /// 2. 相等再比较一下实际内容是否一致
    /// 2.1.获取模型里面的所有成员变量的名字
    NSArray *modelNames = modelUnitSetSqlitePropertiesForClass(cls);
    /// 2.2.获取uid对应数据库里面对应表的字段数组
    NSArray *tableNames = tableUnitSqlitePropertiesForClass(cls);
    /// 2.3.判断两个数组是否相等，返回响应的结果,取反：相等不需要更新，不相等才需要去更新
    return ![modelNames isEqualToArray:tableNames];
}

/// 表更新【处理在初始化时或升级时】
FOUNDATION_EXTERN_INLINE BOOL tableUnitUpdateForClass(Class cls){
    
    /// 1、获取表名
    NSString *tmpTableName = tableUnitTempTableNameForClass(cls);
    NSString *oldTableName = tableUnitTableNameForClass(cls);
    
    /// 创建数组记录执行的sql
    NSMutableArray *execSqls = [NSMutableArray array];
    
    NSString *dropTmpTableSql = [NSString stringWithFormat:@"drop table if exists %@;", tmpTableName];
    [execSqls addObject:dropTmpTableSql];
    
    NSString *primaryKey = [cls taxidb_primaryKey];
    /// 2、获取一个模型里面所有的字段名字，以及类型
    NSString *createTmpTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@));",tmpTableName,tableUnitModelSqlForClass(cls),primaryKey];
    [execSqls addObject:createTmpTableSql];
    
    /// 3、把先把旧表的主键往新表里面插入数据
    NSString *insertPrimaryKeyData = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@;",tmpTableName,primaryKey,primaryKey,oldTableName];
    [execSqls addObject:insertPrimaryKeyData];
    
    /// 4、根据主键把所有 旧表 中的数据更新到 新表 中
    /// 旧表中字段名的数组
    NSArray *oldTableNames = tableUnitSqlitePropertiesForClass(cls);
    /// 获取新模型的所有变量名
    NSArray *tmpTableNames = modelUnitSetSqlitePropertiesForClass(cls);
    
    /// 获取更名字典
    NSDictionary *newNameReplaceOldNameDict = [NSDictionary dictionary];
    if ([cls respondsToSelector:@selector(taxidb_replacedSqliteKeyFromPreviousVersion:)]) {
        NSInteger version = rootTableTableVersionFromCls(cls);
        newNameReplaceOldNameDict = [cls taxidb_replacedSqliteKeyFromPreviousVersion: version];
    }
    
    /// 根据主键 插入新表中有的字段
    for (NSString *columnName in tmpTableNames) {
        /// 找映射的旧的字段的名字
        NSString *oldName = columnName;
        if ([newNameReplaceOldNameDict[oldName] length] != 0) {
            oldName = newNameReplaceOldNameDict[oldName];
        }
        /// 包含主键也过滤掉（上面主键已经赋过值）
        if ((![oldTableNames containsObject:columnName] && ![oldTableNames containsObject:oldName]) || [columnName isEqualToString:primaryKey]) {
            /// 新表中没有的字段就不需要再更新过来了
            continue;
        }
        
        /// 根据主键在新表插入和旧表中一样字段的数据
        NSString *updateSqlStr = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@);",tmpTableName,columnName,oldName,oldTableName,tmpTableName,primaryKey,oldTableName,primaryKey];
        
        [execSqls addObject:updateSqlStr];
    }
    
    /// 5.把旧表删除
    NSString *deleteOldTableSqlStr = [NSString stringWithFormat:@"drop table if exists %@;",oldTableName];
    [execSqls addObject:deleteOldTableSqlStr];
    
    /// 6.把新表的名字改为旧表的名字，就行隐形替换
    NSString *renameTmpTableNameSqlStr = [NSString stringWithFormat:@"alter table %@ rename to %@;",tmpTableName,oldTableName];
    [execSqls addObject:renameTmpTableNameSqlStr];
    
    /// 7.执行上面的sql 语句
    return [TAXIDB dealSqls:execSqls];
}

@end
