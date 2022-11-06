//
//  TaxiRootTableUnit.m
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiRootTableUnit.h"
#import "TaxiDB+Sqlite.h"
#import "TaxiDBModelProtocol.h"
#import "TaxiDBUpdateProtocol.h"

@implementation TaxiRootTableUnit

NSString *rootTableName(void) {
    return @"taxidb_all_tables";
}

NSString *rootTableCreateSql(void) {
    return [NSString stringWithFormat:@"create table if not exists %@(table_name text primary key not null,model_name text default null,version text default null,info1 text default null,info2 text default null,info3 text default null)",rootTableName()];
}

NSString *rootTableSearchSql(NSString *table_name) {
    return [NSString stringWithFormat:@"select table_name from %@ where table_name = '%@'", rootTableName(), table_name];
}

NSString *rootTableInsertSql(NSString *table_name, NSString *model_name, NSString *version) {
    return [NSString stringWithFormat:@"insert into %@ (table_name, model_name, version) values ('%@', '%@', '%@')", rootTableName(), table_name, model_name, version];
}

NSString *rootTableDeleteSql(NSString *table_name) {
    return [NSString stringWithFormat:@"delete from %@", table_name];
}

NSInteger rootTableTableVersionFromCls(Class <TaxiDBModelProtocol>cls) {
    NSString *table_name = [cls taxidb_sqliteTableName];
    NSString *sql = [NSString stringWithFormat:@"select version from %@ where table_name = '%@'", rootTableName(), table_name];
    NSArray *result = [TAXIDB querySql:sql];
    NSDictionary *item = result.firstObject;
    if (item && item.count) {
        return [[item objectForKey:@"version"] intValue];
    }
    return NSNotFound;
}

void rootTableUpdateVersionFrom(NSString *table_name, NSString *version) {
    NSString *sql = [NSString stringWithFormat:@"update %@ set version = '%@' where table_name = '%@'", rootTableName(), version, table_name];
    [TAXIDB dealSql:sql];
}


@end
