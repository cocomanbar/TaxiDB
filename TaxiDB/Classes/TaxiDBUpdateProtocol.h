//
//  TaxiDBUpdateProtocol.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TaxiDBUpdateProtocol <NSObject>

@optional

/// 为每个监听模块获得通知数据库升级的事件，让内部做相应的版本升级工作
/// 需要注意线程以及任务执行导致卡顿
- (void)taxidb_sqliteUpdateTableModel:(Class)cls fromPrevious:(NSUInteger)previousVersion;

@end

NS_ASSUME_NONNULL_END
