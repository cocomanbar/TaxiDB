//
//  TaxiLimitDescription.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiLimitDescription.h"

@interface TaxiLimitDescription ()

@property (nonatomic, copy, readwrite, nullable) NSString *sql;

@end

@implementation TaxiLimitDescription

- (instancetype)initWithSql:(NSString * _Nullable)sql {
    self = [super init];
    if (self) {
        
        _sql = sql;
    }
    return self;
}

@end
