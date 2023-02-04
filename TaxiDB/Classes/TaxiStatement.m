//
//  TaxiStatement.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiStatement.h"

@class TaxiTable;

@interface TaxiCondition (TaxiDB)

- (void)prepareTable:(TaxiTable *)table executeTask:(TaxiTask)taskType buildStatement:(TaxiStatement *)statement;

- (void)packSql;

@end

@interface TaxiStatement ()

@end

@implementation TaxiStatement

- (instancetype)initStatementWithSQL:(NSString * _Nullable)sql {
    return [self initStatementWithSQL:sql values:nil];
}

- (instancetype)initStatementWithSQL:(NSString * _Nullable)sql values:(NSArray * _Nullable)values {
    self = [super init];
    if (self) {
        self.sql = sql;
        self.values = values;
    }
    return self;
}

@end

@implementation TaxiStatement (TaxiDB)

- (void)makeTable:(TaxiTable *)table toSelect:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block {
    TaxiCondition *condition = [[TaxiCondition alloc] init];
    [condition prepareTable:table executeTask:(TaxiTaskSelect) buildStatement:self];
    if (block) {
        block(condition);
    }
    [condition packSql];
}

- (void)makeTable:(TaxiTable *)table toDelete:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block {
    TaxiCondition *condition = [[TaxiCondition alloc] init];
    [condition prepareTable:table executeTask:(TaxiTaskDelete) buildStatement:self];
    if (block) {
        block(condition);
    }
    [condition packSql];
}

- (void)makeTable:(TaxiTable *)table toInsert:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block {
    TaxiCondition *condition = [[TaxiCondition alloc] init];
    [condition prepareTable:table executeTask:(TaxiTaskInsert) buildStatement:self];
    if (block) {
        block(condition);
    }
    [condition packSql];
}

- (void)makeTable:(TaxiTable *)table toUpdatee:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block {
    TaxiCondition *condition = [[TaxiCondition alloc] init];
    [condition prepareTable:table executeTask:(TaxiTaskUpdate) buildStatement:self];
    if (block) {
        block(condition);
    }
    [condition packSql];
}

- (void)makeTable:(TaxiTable *)table toReplace:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block {
    TaxiCondition *condition = [[TaxiCondition alloc] init];
    [condition prepareTable:table executeTask:(TaxiTaskReplace) buildStatement:self];
    if (block) {
        block(condition);
    }
    [condition packSql];
}

@end
