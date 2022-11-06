//
//  TaxiDB.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import <Foundation/Foundation.h>
#import "TaxiRootTableUnit.h"
#import "TaxiTableUnit.h"
#import "TaxiModelUnit.h"
#import "TaxiMapUnit.h"

#import "TaxiDBModelProtocol.h"
#import "TaxiDBUpdateProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define TAXIDB [TaxiDB shared]

@interface TaxiDB : NSObject

/// 支持在使用表的时候触发升级更新，`在表数据量大的情况下可能会造成卡顿`
@property (nonatomic, assign) BOOL autoUpdateTable;

/// 初始化单例
+ (instancetype)shared;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// 通过此方式创建用户数据库, 否则代表公有数据库
- (void)bindingUid:(NSString * _Nullable)uid;
- (void)bindingUid:(NSString * _Nullable)uid dataPath:(NSString * _Nullable)aPath;

/// 检查升级所有表
/// 数据库不设置版本，根表对每一张表都有记录一个信息，其中包括表的版本。
- (void)updateAllTablesIfNeeded;

/// 针对监听数据库表升级的组件模块
- (void)addObserver:(NSObject <TaxiDBUpdateProtocol>*)observer;

@end

NS_ASSUME_NONNULL_END
