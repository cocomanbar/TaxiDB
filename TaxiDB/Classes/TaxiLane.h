//
//  TaxiLane.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 编译后的 `sqlite3_stmt` 语句，缓存以提高执行效率
@interface TaxiLane : NSObject

@property (nonatomic, assign) NSInteger useCount;

@property (nonatomic, copy) NSString *sql;

@property (nonatomic, assign) void *stmt;

@property (nonatomic, assign) BOOL inUse;

// close when db closed
- (void)close;

// reset stmt to reused
- (void)reset;

@end

NS_ASSUME_NONNULL_END
