//
//  TaxiRootTableUnit.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TaxiDBModelProtocol;

@interface TaxiRootTableUnit : NSObject

NSString *rootTableName(void);

NSString *rootTableCreateSql(void);

NSString *rootTableSearchSql(NSString *table_name);

NSString *rootTableInsertSql(NSString *table_name, NSString *model_name, NSString *version);

NSString *rootTableDeleteSql(NSString *table_name);

NSInteger rootTableTableVersionFromCls(Class <TaxiDBModelProtocol>cls);

void rootTableUpdateVersionFrom(NSString *table_name, NSString *version);

@end

NS_ASSUME_NONNULL_END
