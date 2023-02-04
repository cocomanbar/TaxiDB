//
//  TaxiDatabase.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "NSObject+TaxiDB.h"

NS_ASSUME_NONNULL_BEGIN

@class TaxiTable, TaxiStatement;

@interface TaxiDatabase : NSObject

// create a sqlite db. aPath like this：root/user.sqlite
- (nullable instancetype)initWithURL:(NSURL * _Nullable)url;
- (nullable instancetype)initWithPath:(NSString * _Nullable)aPath;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

// sub-class override return sqlite db all tables
- (NSArray <TaxiTable *>* _Nullable)allTables;

// create current sqlite db all table if not exist
- (void)createTablesIfNotExists;

// alert all tables if it needed
- (void)alertTableIfItNeeded;

#pragma mark - SQLite Handle

// sqlite db open state
- (BOOL)isOpen;

// sqlite db open
- (BOOL)open;

// sqlite db close
- (BOOL)close;

// sqlite db in transition
- (BOOL)inTransaction;


#pragma mark - SQLite Crud

// execute a update operation
- (BOOL)executeUpdateStatement:(TaxiStatement * _Nullable)statement;
- (BOOL)executeUpdateStatements:(NSArray <TaxiStatement *>* _Nullable)statements;

// execute a query operation
- (NSArray <NSDictionary *>* _Nullable)executeQueryStatement:(TaxiStatement * _Nullable)statement;


#pragma mark - SQLite Transactions By Database Queue

// execute a rollback operation
- (BOOL)rollback;

// execute a commit operation
- (BOOL)commit;

// executing..
- (BOOL)beginTransaction;
- (BOOL)beginDeferredTransaction;
- (BOOL)beginImmediateTransaction;
- (BOOL)beginExclusiveTransaction;

#pragma mark - SQLite Information

// sqlite version
+ (NSString * _Nullable)sqliteLibVersion;

// log when error
@property (nonatomic, assign) BOOL logsErrors;

// crash when strict error
@property (nonatomic, assign) BOOL crashOnStrictError;

// cache sql lane
@property (nonatomic, assign) BOOL shouldCacheLanes;

// trace log
@property (nonatomic, assign) BOOL traceExecution;

@end

NS_ASSUME_NONNULL_END
