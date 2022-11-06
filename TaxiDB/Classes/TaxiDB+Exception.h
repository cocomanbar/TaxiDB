//
//  TaxiDB+Exception.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiDB.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TaxiDBReport)(NSException *);

@interface TaxiDB (Exception)

+ (void)reportException:(TaxiDBReport)report;

+ (TaxiDBReport)report;

@end

@interface NSException (TaxiDB)

+ (NSException *)taxidb_exceptionWithReason:(NSString * _Nullable)reason userInfo:(NSDictionary * _Nullable)userInfo;

@end

NS_ASSUME_NONNULL_END
