//
//  TaxiDB.m
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiDB.h"
#import "sqlite3.h"

NSLock *dataLock;
NSString *dataPath;
NSString *currentUid;
NSPointerArray *weakObservers;

@implementation TaxiDB

#pragma mark - create and binding uid

+ (instancetype)shared {
    static TaxiDB *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TaxiDB alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        dataLock = [[NSLock alloc] init];
        dataLock.name = @"TaxiDBLock";
        weakObservers = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

/**
 *  创建用户数据库
 */
- (void)bindingUid:(NSString * _Nullable)uid {
    [self bindingUid:uid dataPath:nil];
}

- (void)bindingUid:(NSString * _Nullable)uid dataPath:(NSString * _Nullable)aPath {
    currentUid = uid;
    dataPath = aPath;
    if (!aPath) {
        dataPath = [NSString stringWithFormat:@"%@/Caches/TaxiDB", NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    /// 创建此目录下数据库的`根表`
    [TaxiDB.shared dealSql:rootTableCreateSql()];
}

- (void)addObserver:(NSObject <TaxiDBUpdateProtocol>*)observer {
    if ([observer conformsToProtocol:@protocol(TaxiDBUpdateProtocol)]) {
        [weakObservers addPointer:(__bridge void * _Nullable)(observer)];
    }
    [weakObservers compact];
}

- (void)updateAllTablesIfNeeded {
    
    NSArray *tables = [self querySql:[NSString stringWithFormat:@"select * from %@", rootTableName()]];
    if (!tables || !tables.count) {
        return;
    }
    
    [weakObservers compact];
    
    for (int i = 0; i < tables.count; i++) {
        NSDictionary *tableInfo = tables[i];
        if (![tableInfo isKindOfClass:NSDictionary.class]) {
            continue;
        }
        NSString *version = [tableInfo objectForKey:@"version"];
        NSString *model_name = [tableInfo objectForKey:@"model_name"];
        NSString *table_name = [tableInfo objectForKey:@"table_name"];
        if (!version || !model_name || !table_name) {
            continue;
        }
        Class cls = NSClassFromString(model_name);
        if (!cls || ![cls conformsToProtocol:@protocol(TaxiDBModelProtocol)]) {
            continue;
        }
        
        if (tableUnitNeedUpdateForClass(cls) == false) {
            continue;
        }
        
        for (int j = 0; j < weakObservers.count; j++) {
            id <TaxiDBUpdateProtocol>objc = (__bridge id)[weakObservers pointerAtIndex:j];
            if ([objc respondsToSelector:@selector(taxidb_sqliteUpdateTableModel:fromPrevious:)]) {
                [objc taxidb_sqliteUpdateTableModel:cls fromPrevious:[version intValue]];
            }
        }
    }
}

#pragma mark - 增删改sql

- (BOOL)dealSql:(NSString *)sql{
    return [self handleSqliteWithBlock:^BOOL(sqlite3 *database) {
        sqlite3_stmt *stmt = nil;
        if (sqlite3_prepare_v2(database, sql.UTF8String, -1, &stmt, nil) != SQLITE_OK) {
            #ifdef DEBUG
            NSLog(@"[TaxiDB]：准备语句编译失败！sql = %@", sql);
            #endif
            sqlite3_finalize(stmt);
            return NO;
        }
        sqlite3_finalize(stmt);
        return (sqlite3_exec(database, sql.UTF8String, nil, nil, nil) == SQLITE_OK);
    }];
}

- (BOOL)dealSqls:(NSArray <NSString *>*)sqls{
    if (sqls.count == 0) {
        return NO;
    }
    return [self handleSqliteWithBlock:^BOOL(sqlite3 *database) {
        /// 开始事务
        sqlite3_exec(database, @"begin transaction".UTF8String, nil, nil, nil);
        for (NSString *sql in sqls) {
            if ((sqlite3_exec(database, sql.UTF8String, nil, nil, nil) != SQLITE_OK)) {
                #ifdef DEBUG
                NSLog(@"[TaxiDB]：执行多条sql时，此条sql执行失败：%@", sql);
                #endif
                /// 回滚事务
                sqlite3_exec(database, @"rollback transaction".UTF8String, nil, nil, nil);
                return NO;
            }
        }
        /// 提交事务
        sqlite3_exec(database, @"commit transaction".UTF8String, nil, nil, nil);
        return YES;
    }];
}

#pragma mark - 查sql

- (NSMutableArray <NSMutableDictionary *>*)querySql:(NSString *)sql{
    __block NSMutableArray<NSMutableDictionary *>* infos = NSMutableArray.array;
    [self handleSqliteWithBlock:^BOOL(sqlite3 *database) {
        /**
         1.准备语句，预处理语句
         第1个参数：一个已经打开的数据库对象
         第2个参数：sql语句
         第3个参数：参数2中取出多少字节的长度，-1 自动计算，\0停止取出
         第4个参数：准备语句
         第5个参数：通过参数3，取出参数2的长度字节之后，剩下的字符串
         */
        sqlite3_stmt *stmt = nil;
        if (sqlite3_prepare_v2(database, sql.UTF8String, -1, &stmt, nil) != SQLITE_OK) {
            #ifdef DEBUG
            NSLog(@"[TaxiDB]：准备语句编译失败！sql = %@", sql);
            #endif
            return NO;
        }
        
        NSMutableArray *rowArray = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) { ///SQLITE_ROW代表数据的不断的向下查找
            /// 一行记录 代表 字典对象
            NSMutableDictionary *rowDictionary = [NSMutableDictionary dictionary];
            
            /// 1、获取所有列的个数
            int columnCount = sqlite3_column_count(stmt);
            
            /// 2、遍历所有的列
            for (int i=0; i<columnCount; i++) {
                
                /// 2.1、获取所有列的名字，也就是表中字段的名字
                /// C语言的字符串
                const char *columnNameC = sqlite3_column_name(stmt, i);
                /// 把 C 语言字符串转为 OC
                NSString *columnName = [NSString stringWithUTF8String:columnNameC];
                /// 2.2、获取列值
                /// 不同列的类型，使用不同的函数，进行获取值
                /// 2.3、获取列的类型
                int type = sqlite3_column_type(stmt, i);
                /**
                 我们使用的是 SQLite3，所以是：SQLITE3_TEXT
                 SQLite version 2 and SQLite version 3 should use SQLITE3_TEXT
                 SQLITE_INTEGER  1
                 SQLITE_FLOAT    2
                 SQLITE3_TEXT    3
                 SQLITE_BLOB     4
                 SQLITE_NULL     5
                 */
                /// 2.4、根据列的类型，使用不同的函数，获取列的值
                id value = nil;
                switch (type) {
                    case SQLITE_INTEGER:
                        value = @(sqlite3_column_int(stmt,i));
                        break;
                    case SQLITE_FLOAT:
                        value = @(sqlite3_column_double(stmt, i));
                        break;
                    case SQLITE3_TEXT:
                        value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)];
                        break;
                    case SQLITE_BLOB:
                        value = CFBridgingRelease(sqlite3_column_blob(stmt, i));
                        break;
                    case SQLITE_NULL:
                        value = nil;
                        break;
                        
                    default:
                        break;
                }
                /// 2.5、字典填值，安全检查噶
                if (value && columnName) {
                    [rowDictionary setValue:value forKey:columnName];
                }
            }
            
            /// 2.6、每一个添加到数组
            if (rowDictionary.count) {
                [rowArray addObject:rowDictionary];
            }
        }
        /// 3、释放资源
        sqlite3_finalize(stmt);
        
        /// 4、赋值
        infos = rowArray;
        
        return YES;
    }];
    
    return infos;
}

#pragma mark - Private

- (BOOL)handleSqliteWithBlock:(BOOL (^)(sqlite3 *database))block{
    sqlite3 *database;
    NSString *path = databasePath();
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        return NO;
    }
    BOOL result = YES;
    if (block) {
        [dataLock lock];
        result = block(database);
        [dataLock unlock];
    }
    sqlite3_close(database);
    return result;
}

FOUNDATION_STATIC_INLINE NSString *databasePath(){
    if (!currentUid || !currentUid.length) {
        return [NSString stringWithFormat:@"%@/public_taxiDB.db", dataPath];
    }
    return [NSString stringWithFormat:@"%@/%@_taxiDB.db", dataPath, currentUid];
}

- (double)runtimeForBlock:(void(^)(void))runBlock{
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    if (runBlock) {
        runBlock();
    }
    CFAbsoluteTime deltaTime = (CFAbsoluteTimeGetCurrent() - start) * 1000;
    NSLog(@"[此次运行耗时] cost time = %f ms", deltaTime);
    return deltaTime;
}

@end
