//
//  TaxiTable.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>
#import "TaxiField.h"
#import "TaxiDatabase.h"
#import "TaxiStatement.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaxiTable : NSObject

@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, weak, readonly, nullable) TaxiDatabase *dataBase;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithDatabase:(TaxiDatabase * _Nullable)dataBase;


- (nullable NSArray <TaxiField *>*)liteFields;
- (nullable NSArray <TaxiField *>*)liteAlertFields;

// 升级新增的字段
- (void)alertTableIfItNeeded;

// 清空表
- (void)deleteTableIfItNeeded;

@end

NS_ASSUME_NONNULL_END
