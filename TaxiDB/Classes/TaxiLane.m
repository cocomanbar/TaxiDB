//
//  TaxiLane.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiLane.h"
#import <sqlite3.h>

@implementation TaxiLane

- (void)close {
    
    if (_stmt) {
        sqlite3_finalize(_stmt);
        _stmt = 0x00;
    }
    _inUse = NO;
}

- (void)reset {
    
    if (_stmt) {
        sqlite3_reset(_stmt);
    }
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"sql：%@，useCount：%ld", _sql, (long)_useCount];
}

- (void)dealloc {
    
    [self close];
}

@end
