//
//  TaxiDatabaseQueue.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiDatabaseQueue.h"

typedef NS_ENUM(NSInteger, TaxiDBTransaction) {
    TaxiDBTransactionExclusive,
    TaxiDBTransactionDeferred,
    TaxiDBTransactionImmediate,
};

static const void * const kTaxiDBDispatchQueueSpecificKey = &kTaxiDBDispatchQueueSpecificKey;

@interface TaxiDatabaseQueue ()

@property (nonatomic, strong) TaxiDatabase *database;
@property (nonatomic, strong) dispatch_queue_t insideQueue;
@property (nonatomic, strong) dispatch_queue_t businessQueue;

@end

@implementation TaxiDatabaseQueue

- (dispatch_queue_t)insideQueue {
    if (!_insideQueue) {
        _insideQueue = dispatch_queue_create([[NSString stringWithFormat:@"com.sqlite.%@", self] UTF8String], NULL);
        // dispatch_queue_set_specific
        dispatch_queue_set_specific(_insideQueue, kTaxiDBDispatchQueueSpecificKey, (__bridge void *)self, NULL);
    }
    return _insideQueue;
}

- (dispatch_queue_t)getQueue {
    if (_businessQueue) {
        return _businessQueue;
    }
    return self.insideQueue;
}

// create a database queue by wraped a db
- (nullable instancetype)initWithDataBase:(TaxiDatabase * _Nullable)database {
    if (!database) {
        return 0x00;
    }
    self = [super init];
    if (self) {
        
        _database = database;

        // default open db
        if (![self isOpen]) {
            [self.database open];
            [self.database createTablesIfNotExists];
            [self.database alertTableIfItNeeded];
        }
    }
    return self;
}

- (BOOL)isOpen {
    __block BOOL ret = false;
    dispatch_sync([self getQueue], ^() {
        ret = [self.database isOpen];
    });
    return ret;
}

- (BOOL)open {
    if (![self isOpen]) {
        __block BOOL ret = false;
        dispatch_sync([self getQueue], ^() {
            ret = [self.database open];
        });
        return ret;
    }
    return true;
}

- (BOOL)close {
    if ([self isOpen]) {
        __block BOOL ret = false;
        dispatch_sync([self getQueue], ^() {
            ret = [self.database close];
        });
        return ret;
    }
    return true;
}

- (void)setBusinessQueue:(dispatch_queue_t)aQueue {
    if (!aQueue) {
        NSAssert((!aQueue), @"work queue invalid");
        return;
    }
    if (_businessQueue && _businessQueue == aQueue) {
        return;
    }
    _businessQueue = nil;
    _businessQueue = aQueue;
    dispatch_queue_set_specific(_businessQueue, kTaxiDBDispatchQueueSpecificKey, (__bridge void *)self, NULL);
}


- (void)inDatabase:(void (^)(TaxiDatabase *db))block {
#ifndef NDEBUG
    /* Get the currently executing queue (which should probably be nil, but in theory could be another DB queue
     * and then check it against self to make sure we're not about to deadlock. */
    TaxiDatabaseQueue *currentSyncQueue = (__bridge id)dispatch_get_specific(kTaxiDBDispatchQueueSpecificKey);
    assert(currentSyncQueue != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");
#endif
    dispatch_sync([self getQueue], ^() {
        TaxiDatabase *db = [self database];
        block(db);
    });
}

- (void)inTransaction:(void (^)(TaxiDatabase *db, BOOL *rollback))block {
    [self beginTransaction:TaxiDBTransactionExclusive withBlock:block];
}

- (void)inDeferredTransaction:(void (^)(TaxiDatabase *db, BOOL *rollback))block {
    [self beginTransaction:TaxiDBTransactionDeferred withBlock:block];
}

- (void)inExclusiveTransaction:(void (^)(TaxiDatabase *db, BOOL *rollback))block {
    [self beginTransaction:TaxiDBTransactionExclusive withBlock:block];
}

- (void)inImmediateTransaction:(void (^)(TaxiDatabase *db, BOOL *rollback))block {
    [self beginTransaction:TaxiDBTransactionImmediate withBlock:block];
}

- (void)beginTransaction:(TaxiDBTransaction)transaction withBlock:(void (^)(TaxiDatabase *db, BOOL *rollback))block {
    
    dispatch_sync([self getQueue], ^() {
        
        BOOL shouldRollback = NO;

        switch (transaction) {
            case TaxiDBTransactionExclusive:
                [[self database] beginTransaction];
                break;
            case TaxiDBTransactionDeferred:
                [[self database] beginDeferredTransaction];
                break;
            case TaxiDBTransactionImmediate:
                [[self database] beginImmediateTransaction];
                break;
        }
        
        block([self database], &shouldRollback);
        
        if (shouldRollback) {
            [[self database] rollback];
        }else {
            [[self database] commit];
        }
    });
}

@end
