//
//  tomato+wcdb.h
//  TaxiDB_Example
//
//  Created by tanxl on 2022/11/7.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "tomato.h"

NS_ASSUME_NONNULL_BEGIN

@interface tomato (wcdb)

+ (BOOL)deleteAllitemIdBelowFromCatgory;

+ (BOOL)updateStatusAllMovingToStop;

+ (NSArray *)searchDatasWithSQL;

+ (BOOL)deleteAllDatasFromTable;

@end

NS_ASSUME_NONNULL_END
