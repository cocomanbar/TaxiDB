//
//  TaxiDB+Sqlite.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaxiDB ()

- (BOOL)dealSql:(NSString *)sql;

- (BOOL)dealSqls:(NSArray <NSString *>*)sqls;

- (NSMutableArray <NSMutableDictionary *>*)querySql:(NSString *)sql;

- (double)runtimeForBlock:(void(^)(void))runBlock;

@end

NS_ASSUME_NONNULL_END
