//
//  TaxiMapUnit.m
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiMapUnit.h"
#import "TaxiDB+Sqlite.h"
#import "TaxiDBModelProtocol.h"
#import "TaxiDBUpdateProtocol.h"

@implementation TaxiMapUnit

NSString *mapUnitModelSqlForClass_(NSDictionary *map, NSString *primaryKey){
    NSMutableArray *result = [NSMutableArray array];
    __block BOOL has_primaryKey = NO;
    [map enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if (![key isKindOfClass:NSString.class] || ![value isKindOfClass:NSString.class]) {
            /**
            *  支持针对字典映射数据库 [key - value]
            *
            *  注意如下要求：
            *  key         必须是NSString
            *  value       必须是NSString
            *
            *  不强制规定类型，后续会面临很多问题，比如生成表时，搜索结果时，更新数据时都要考虑到传一个原始类型Map进来才知道value的具体类型
            *  Map毕竟没有模型表现那么丰富多样
            */
            NSCAssert(NO, @"未按照规定生成字典");
        }
        if ([key isEqualToString:primaryKey]) {
            has_primaryKey = YES;
        }
        [result addObject:[NSString stringWithFormat:@"%@ %@", key ,@"text"]];
    }];
    if (!has_primaryKey) {
        NSCAssert(NO, @"未存在主键字段");
    }
    return [result componentsJoinedByString:@","];
}

NSArray *mapUnitTableSqlitePropertiesForClass_(NSString *tableName){
    
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
       studentNumber text
       studentAge text
       studentScore text
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

@end
