//
//  TaxiDatabase.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiDatabase.h"
#import "TaxiLane.h"
#import "TaxiTable+TaxiDB.h"

@interface TaxiDatabase ()
{
    sqlite3 *_database;
    
    BOOL _isOpen;
    BOOL _inTransaction;
    BOOL _isExecutingStatement;
}

@property (nonatomic, copy) NSString *databasePath;

// dictionary of cached <sql : Set<lane(sqlite3_stmt)>>
@property (nonatomic, strong) NSMutableDictionary *cachedLanes;

@end

@implementation TaxiDatabase

#pragma mark - create

- (nullable instancetype)initWithURL:(NSURL * _Nullable)url {
    return [self initWithPath:url.path];
}

- (nullable instancetype)initWithPath:(NSString * _Nullable)aPath {
    
    assert(sqlite3_threadsafe()); // whoa there big boy- gotta make sure sqlite it happy with what we're going to do.
    
    self = [super init];
    
    if (self) {
        
        NSAssert(([aPath isKindOfClass:NSString.class] || aPath.length > 0), @"null path.");
        _databasePath = aPath;
    }
    return self;
}

- (NSArray<TaxiTable *> *)allTables {
    return nil;
}

- (void)createTablesIfNotExists {
    
    NSArray<TaxiTable *> *tables = [self allTables];
    if (!tables || tables.count == 0) {
        return;
    }
    NSMutableArray<TaxiStatement *> *statementArray = [NSMutableArray arrayWithCapacity:tables.count];
    for (TaxiTable *table in tables) {
        TaxiStatement *statement = [table createTableSQL];
        if (!statement) {
            continue;
        }
        [statementArray addObject:statement];
    }
    
    BOOL ret = [self executeUpdateStatements:statementArray];
    NSAssert(ret, @"Exist errors when Created tables");
}

- (void)alertTableIfItNeeded {
    NSArray<TaxiTable *> *tables = [self allTables];
    if (!tables || tables.count == 0) {
        return;
    }
    for (TaxiTable *table in tables) {
        [table alertTableIfItNeeded];
    }
}

- (void)dealloc {
    
    [self close];
}

#pragma mark - SQLite Handle

-(BOOL)isOpen {
    
    return _isOpen;
}

- (BOOL)open {
    if (_isOpen) {
        return true;
    }
    
    if (_database) {
        [self close];
    }
    
    // now open database
    
    int err = sqlite3_open([[self databasePath] UTF8String] , (sqlite3**)&_database );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return false;
    }
    
    _isOpen = YES;
    
    return true;
}

- (BOOL)close {
    
    [self clearSQLiteLaneCache];
    
    if (!_database) {
        _isOpen = false;
        return true;
    }
    
    int  rc;
    BOOL retry;
    BOOL triedFinalizingOpenStatements = NO;
    
    do {
        retry   = false;
        rc      = sqlite3_close(_database);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = true;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(_database, nil)) != 0) {
                    NSLog(@"Closing leaked statement");
                    sqlite3_finalize(pStmt);
                    retry = true;
                }
            }
        }
        else if (SQLITE_OK != rc) {
            NSLog(@"error closing!: %d", rc);
        }
    }
    while (retry);
    
    _database = nil;
    _isOpen = false;
    
    return true;
}

- (BOOL)databaseExists {
    
    if (!_isOpen) {
        NSLog(@"The Database %@ is not open.", self);
        if (_crashOnStrictError) {
            NSAssert(false, @"The Database %@ is not open.", self);
            abort();
        }
        return false;
    }
    return true;
}

#pragma mark - SQLite crud

- (BOOL)executeUpdateStatements:(NSArray <TaxiStatement *>* _Nullable)statements {
    
    if (!statements || statements.count == 0) {
        return false;
    }
    
    BOOL error = false;
    
    for (TaxiStatement *statement in statements) {
        if (![self executeUpdateStatement:statement]) {
            error = true;
        }
    }
    
    return !error;
}

- (BOOL)executeUpdateStatement:(TaxiStatement * _Nullable)statement {
    
    if (!statement || statement.sql.length == 0) {
        return false;
    }
    
    if (![self databaseExists]) {
        return false;
    }
    
    if (_isExecutingStatement) {
        NSLog(@"The Database %@ is currently in use.", self);
        if (_crashOnStrictError) {
            NSAssert(false, @"The Database %@ is currently in use.", self);
            abort();
        }
        return false;
    }
    
    _isExecutingStatement = YES;
        
    int rc                  = 0x00;
    sqlite3_stmt *stmt      = 0x00;
    TaxiLane *lane        = 0x00;

    NSString *sql = [statement sql];
    NSArray  *values = [statement values];
    
    if (_shouldCacheLanes) {
        lane = [self cachedLaneForSql:sql];
        if (lane){
            stmt = [lane stmt];
            [lane reset];
            
            if (_traceExecution) {
                NSLog(@"lane: %@", lane.description);
            }
        }
    }
    
    if (!stmt) {
        rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, 0);
        
        if (SQLITE_OK != rc) {
            
            if (_crashOnStrictError) {
                NSAssert(false, @"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                abort();
            }
            
            sqlite3_finalize(stmt);
            _isExecutingStatement = false;
            return false;
        }
    }
    
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(stmt); // pointed out by Dominic Yu (thanks!)
    
    while (idx < queryCount) {
        
        if (values && idx < (int)[values count]) {
            obj = [values objectAtIndex:(NSUInteger)idx];
        }else {
            //We ran out of arguments
            break;
        }
        
        if (_traceExecution) {
            if ([obj isKindOfClass:[NSData class]]) {
                NSLog(@"data: %ld bytes", (unsigned long)[(NSData*)obj length]);
            }else {
                NSLog(@"obj: %@", obj);
            }
        }
        
        idx++;
        
        [self bindObject:obj toColumn:idx inStatement:stmt];
    }
    
    if (idx != queryCount) {
        NSLog(@"Error: the bind count is not correct for the # of variables (executeQuery)");
        sqlite3_finalize(stmt);
        _isExecutingStatement = false;
        return false;
    }
    
    rc = sqlite3_step(stmt);
    
    if (SQLITE_DONE == rc) {
        // all is well, let's return.
    }
    else if (SQLITE_INTERRUPT == rc) {
        if (_logsErrors) {
            NSLog(@"Error calling sqlite3_step. Query was interrupted (%d: %@) SQLITE_INTERRUPT", rc, [self lastErrorMessage]);
            NSLog(@"DB Query: %@", sql);
        }
    }
    else if (SQLITE_ROW == rc) {
        NSString *message = [NSString stringWithFormat:@"A executeUpdate is being called with a query string '%@'", sql];
        if (_logsErrors) {
            NSLog(@"%@", message);
            NSLog(@"DB Query: %@", sql);
        }
    }
    else {
        if (SQLITE_ERROR == rc) {
            if (_logsErrors) {
                NSLog(@"Error calling sqlite3_step (%d: %@) SQLITE_ERROR", rc, [self lastErrorMessage]);
                NSLog(@"DB Query: %@", sql);
            }
        }
        else if (SQLITE_MISUSE == rc) {
            // uh oh.
            if (_logsErrors) {
                NSLog(@"Error calling sqlite3_step (%d: %@) SQLITE_MISUSE", rc, [self lastErrorMessage]);
                NSLog(@"DB Query: %@", sql);
            }
        }
        else {
            // wtf?
            if (_logsErrors) {
                NSLog(@"Unknown error calling sqlite3_step (%d: %@) eu", rc, [self lastErrorMessage]);
                NSLog(@"DB Query: %@", sql);
            }
        }
    }
    
    if (_shouldCacheLanes && !lane) {
        if (!lane) {
            lane = [[TaxiLane alloc] init];
            [lane setStmt:stmt];
        }
        [self setCachedLane:lane forSql:sql];
    }
    
    int closeErrorCode;
    
    if (lane) {
        closeErrorCode = sqlite3_reset(stmt);
        [lane setUseCount:lane.useCount + 1];
        [lane setInUse:false];
    } else {
        /* Finalize the virtual machine. This releases all memory and other
         * resources allocated by the sqlite3_prepare() call above.
         */
        closeErrorCode = sqlite3_finalize(stmt);
    }
    
    if (SQLITE_OK != closeErrorCode) {
        if (_logsErrors) {
            NSLog(@"Unknown error finalizing or resetting statement (%d: %@)", closeErrorCode, [self lastErrorMessage]);
            NSLog(@"DB Query: %@", sql);
        }
    }
    
    _isExecutingStatement = false;
    
    return (rc == SQLITE_DONE || rc == SQLITE_OK);
}


- (NSArray <NSDictionary *>* _Nullable)executeQueryStatement:(TaxiStatement * _Nullable)statement {
    
    __block NSMutableArray<NSMutableDictionary *>* resultArray = NSMutableArray.array;
    
    if (!statement || statement.sql.length == 0) {
        return [resultArray copy];
    }
    
    if (![self databaseExists]) {
        return [resultArray copy];
    }
    
    if (_isExecutingStatement) {
        NSLog(@"The Database %@ is currently in use.", self);
        if (_crashOnStrictError) {
            NSAssert(false, @"The Database %@ is currently in use.", self);
            abort();
        }
        return false;
    }
    
    _isExecutingStatement = YES;
    
    int rc                  = 0x00;
    sqlite3_stmt *stmt      = 0x00;
    TaxiLane *lane        = 0x00;
    
    NSString *sql = [statement sql];
    NSArray  *values = [statement values];
    
    if (_shouldCacheLanes) {
        lane = [self cachedLaneForSql:sql];
        if (lane){
            stmt = [lane stmt];
            [lane reset];
            
            if (_traceExecution) {
                NSLog(@"lane: %@", lane.description);
            }
        }
    }
    
    if (!stmt) {
        /**
         1.准备语句，预处理语句
         第1个参数：一个已经打开的数据库对象
         第2个参数：sql语句
         第3个参数：参数2中取出多少字节的长度，-1 自动计算，\0停止取出
         第4个参数：准备语句
         第5个参数：通过参数3，取出参数2的长度字节之后，剩下的字符串
         */
        rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, 0);
        
        if (SQLITE_OK != rc) {
            
            if (_logsErrors) {
                NSLog(@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                NSLog(@"DB Query: %@", sql);
                NSLog(@"DB Path: %@", _databasePath);
            }
            
            if (_crashOnStrictError) {
                NSAssert(false, @"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                abort();
            }
            
            sqlite3_finalize(stmt);
            _isExecutingStatement = false;
            return [resultArray copy];
        }
    }
    
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(stmt); // pointed out by Dominic Yu (thanks!)
    
    while (idx < queryCount) {
        
        if (values && idx < (int)[values count]) {
            obj = [values objectAtIndex:(NSUInteger)idx];
        }else {
            //We ran out of arguments
            break;
        }
        
        if (_traceExecution) {
            if ([obj isKindOfClass:[NSData class]]) {
                NSLog(@"data: %ld bytes", (unsigned long)[(NSData*)obj length]);
            }else {
                NSLog(@"obj: %@", obj);
            }
        }
        
        idx++;
        
        [self bindObject:obj toColumn:idx inStatement:stmt];
    }
    
    if (idx != queryCount) {
        NSLog(@"Error: the bind count is not correct for the # of variables (executeQuery)");
        sqlite3_finalize(stmt);
        _isExecutingStatement = false;
        return [resultArray copy];
    }
    
    if (_shouldCacheLanes && !lane) {
        if (!lane) {
            lane = [[TaxiLane alloc] init];
            [lane setStmt:stmt];
        }
        [self setCachedLane:lane forSql:sql];
    }
    
    ///SQLITE_ROW代表数据的不断的向下查找
    while (SQLITE_ROW == sqlite3_step(stmt)) {

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
                    value = [NSNumber numberWithInteger:sqlite3_column_int64(stmt,i)];
                    break;
                case SQLITE_FLOAT:
                    value = [NSNumber numberWithDouble:sqlite3_column_double(stmt, i)];
                    break;
                case SQLITE3_TEXT:
                {
                    const char *c = (const char *)sqlite3_column_text(stmt, i);
                    if (c) {
                        value = [NSString stringWithUTF8String:c];
                    }
                }
                    break;
                case SQLITE_BLOB:
                {
                    int dataSize = sqlite3_column_bytes(stmt, i);
                    const char *dataBuffer = sqlite3_column_blob(stmt, i);
                    value = [NSData dataWithBytesNoCopy:(void *)dataBuffer length:(NSUInteger)dataSize freeWhenDone:NO];
                }
                    break;
                case SQLITE_NULL:
                    value = nil;
                    break;

                default:
                    NSAssert(false, @"");
                    break;
            }

            /// 2.5、字典填值，安全检查噶
            if (value && columnName) {
                [rowDictionary setValue:value forKey:columnName];
            }
        }

        /// 2.6、每一个添加到数组
        if (rowDictionary.count > 0) {
            [resultArray addObject:rowDictionary];
        }
    }

    /// 3、处理资源
    if (lane) {
        [lane setUseCount:lane.useCount + 1];
        [lane reset];
        [lane setInUse:false];
    } else {
        /* Finalize the virtual machine. This releases all memory and other
         * resources allocated by the sqlite3_prepare() call above.
         */
        sqlite3_finalize(stmt);
        stmt = 0x00;
    }
    
    _isExecutingStatement = false;
    
    return [resultArray copy];
}

#pragma mark SQL manipulation

// binding objc to sqlite3_stmt
- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt {
    
    if ((!obj) || ((NSNull *)obj == [NSNull null])) {
        sqlite3_bind_null(pStmt, idx);
    }
    
    // FIXME - someday check the return codes on these binds.
    else if ([obj isKindOfClass:[NSData class]]) {
        const void *bytes = [obj bytes];
        if (!bytes) {
            // it's an empty NSData object, aka [NSData data].
            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
            bytes = "";
        }
        sqlite3_bind_blob(pStmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        
        if (strcmp([obj objCType], @encode(char)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj charValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned char)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj unsignedCharValue]);
        }
        else if (strcmp([obj objCType], @encode(short)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj shortValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned short)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj unsignedShortValue]);
        }
        else if (strcmp([obj objCType], @encode(int)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj intValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned int)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedIntValue]);
        }
        else if (strcmp([obj objCType], @encode(long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongValue]);
        }
        else if (strcmp([obj objCType], @encode(long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongLongValue]);
        }
        else if (strcmp([obj objCType], @encode(float)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj floatValue]);
        }
        else if (strcmp([obj objCType], @encode(double)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        else if (strcmp([obj objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
        }
        else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    else {
        sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
}

#pragma mark - SQLite Cache Lane

- (void)clearSQLiteLaneCache {
    
    for (NSMutableSet *lanes in [self.cachedLanes objectEnumerator]) {
        for (TaxiLane *lane in [lanes allObjects]) {
            [lane close];
        }
    }
    
    [self.cachedLanes removeAllObjects];
}

- (void)setCachedLane:(TaxiLane *)lane forSql:(NSString *)sql {
    NSParameterAssert(sql);
    if (!sql) {
        return;
    }
    
    // in case we got handed in a mutable string...
    sql = [sql copy];
    [lane setSql:sql];
    
    NSMutableSet *lanes = [self.cachedLanes objectForKey:sql];
    if (!lanes) {
        lanes = [NSMutableSet set];
    }
    
    [lanes addObject:lane];
    
    [self.cachedLanes setObject:lanes forKey:sql];
}

- (TaxiLane *)cachedLaneForSql:(NSString *)sql {
    
    NSMutableSet *lanes = [self.cachedLanes objectForKey:sql];
    
    if (!lanes) {
        return nil;
    }
    
    TaxiLane *lane = [[lanes objectsPassingTest:^BOOL(TaxiLane *lane, BOOL *stop) {
        *stop = ![lane inUse];
        return *stop;
    }] anyObject];
    
    [lane setInUse:true];
    
    return lane;
}

#pragma mark - SQLite Transactions

- (BOOL)rollback {
    TaxiStatement *statement = [[TaxiStatement alloc] initStatementWithSQL:@"rollback transaction"];
    BOOL ret = [self executeUpdateStatement:statement];
    if (ret) {
        _inTransaction = false;
    }
    return ret;
}

- (BOOL)commit {
    TaxiStatement *statement = [[TaxiStatement alloc] initStatementWithSQL:@"commit transaction"];
    BOOL ret = [self executeUpdateStatement:statement];
    if (ret) {
        _inTransaction = false;
    }
    return ret;
}

- (BOOL)beginTransaction {
    TaxiStatement *statement = [[TaxiStatement alloc] initStatementWithSQL:@"begin exclusive transaction"];
    BOOL ret = [self executeUpdateStatement:statement];
    if (ret) {
        _inTransaction = true;
    }
    return ret;
}

- (BOOL)beginDeferredTransaction {
    TaxiStatement *statement = [[TaxiStatement alloc] initStatementWithSQL:@"begin deferred transaction"];
    BOOL ret = [self executeUpdateStatement:statement];
    if (ret) {
        _inTransaction = true;
    }
    return ret;
}

- (BOOL)beginImmediateTransaction {
    TaxiStatement *statement = [[TaxiStatement alloc] initStatementWithSQL:@"begin immediate transaction"];
    BOOL ret = [self executeUpdateStatement:statement];
    if (ret) {
        _inTransaction = true;
    }
    return ret;
}

- (BOOL)beginExclusiveTransaction {
    TaxiStatement *statement = [[TaxiStatement alloc] initStatementWithSQL:@"begin exclusive transaction"];
    BOOL ret = [self executeUpdateStatement:statement];
    if (ret) {
        _inTransaction = true;
    }
    return ret;
}

- (BOOL)inTransaction {
    return _inTransaction;
}


#pragma mark - SQLite information

+ (NSString *)sqliteLibVersion {
    return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}

- (int)lastErrorCode{
    return sqlite3_errcode(_database);
}

- (NSString *)lastErrorMessage {
    return [NSString stringWithUTF8String:sqlite3_errmsg(_database)];
}

#pragma mark - Getter

- (NSMutableDictionary *)cachedLanes {
    if (!_cachedLanes) {
        _cachedLanes = [NSMutableDictionary dictionary];
    }
    return _cachedLanes;
}

@end
