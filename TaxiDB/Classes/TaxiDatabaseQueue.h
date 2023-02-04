//
//  TaxiDatabaseQueue.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>
#import "TaxiDatabase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaxiDatabaseQueue<ObjectType: TaxiDatabase *> : NSObject

@property (nonatomic, strong, readonly, nullable) ObjectType database;

// create a database queue by wraped a db
// default to executing `db.createTablesIfNotExists` and `db.alertTableIfItNeeded`
- (nullable instancetype)initWithDataBase:(ObjectType _Nullable)database;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

// default open db, also control db open status by user
- (BOOL)isOpen;
- (BOOL)open;
- (BOOL)close;

// work queue, also control it by user, inside use 'strong' to hold it
- (void)setBusinessQueue:(dispatch_queue_t)aQueue;


- (void)inDatabase:(void (^)(ObjectType db))block;

- (void)inTransaction:(void (^)(ObjectType db, BOOL *rollback))block;

- (void)inDeferredTransaction:(void (^)(ObjectType db, BOOL *rollback))block;

- (void)inExclusiveTransaction:(void (^)(ObjectType db, BOOL *rollback))block;

- (void)inImmediateTransaction:(void (^)(ObjectType db, BOOL *rollback))block;

@end

NS_ASSUME_NONNULL_END
