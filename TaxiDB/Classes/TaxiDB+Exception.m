//
//  TaxiDB+Exception.m
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiDB+Exception.h"

@implementation TaxiDB (Exception)

static TaxiDBReport _report;
+ (void)reportException:(TaxiDBReport)report {
    _report = report;
}

+ (TaxiDBReport)report {
    return _report;
}

@end

@implementation NSException (TaxiDB)

+ (NSException *)taxidb_exceptionWithReason:(NSString * _Nullable)reason userInfo:(NSDictionary * _Nullable)userInfo {
    NSException *exc = [NSException exceptionWithName:@"com.taxiDB.exception" reason:reason userInfo:userInfo];
    return exc;
}

@end
