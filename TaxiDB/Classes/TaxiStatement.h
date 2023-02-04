//
//  TaxiStatement.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>
#import "TaxiCondition.h"

NS_ASSUME_NONNULL_BEGIN

@class TaxiTable;

/**
 *  两种执行sql的方式：
 *      1）执行一条完整的sql，无values值，这种可能是简单的sql或拼接完整后的sql
 *      2）执行一条带values值的sql，内部预编译stmt语句绑定参数values值
 */
@interface TaxiStatement : NSObject

// sql语句
@property (nonatomic, copy, nullable) NSString *sql;

// sql语句里 ? 对应的值，和sql对应的顺序一致
@property (nonatomic, copy, nullable) NSArray<id> *values;


- (instancetype)initStatementWithSQL:(NSString * _Nullable)sql;
- (instancetype)initStatementWithSQL:(NSString * _Nullable)sql values:(NSArray * _Nullable)values;

@end

@interface TaxiStatement (TaxiDB)

- (void)makeTable:(TaxiTable *)table toSelect:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block;
- (void)makeTable:(TaxiTable *)table toDelete:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block;
- (void)makeTable:(TaxiTable *)table toInsert:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block;
- (void)makeTable:(TaxiTable *)table toUpdatee:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block;
- (void)makeTable:(TaxiTable *)table toReplace:(void(NS_NOESCAPE ^)(TaxiCondition * _Nonnull make))block;

@end


NS_ASSUME_NONNULL_END
