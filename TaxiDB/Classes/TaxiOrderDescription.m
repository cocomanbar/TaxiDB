//
//  TaxiOrderDescription.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiOrderDescription.h"

@interface TaxiOrderDescription ()

@property (nonatomic, copy, readwrite, nullable) NSString *sql;

@end

@implementation TaxiOrderDescription

- (instancetype)initWithName:(NSString * _Nullable)name orderBy:(TaxiOrderBy)orderBy {
    self = [super init];
    if (self) {
        
        if (name) {
            NSString *desc  = orderBy == TaxiOrderByASC ? @"ASC" : @"DESC";
            _sql = [NSString stringWithFormat:@"ORDER BY %@ %@", name, desc];
        }
    }
    return self;
}

@end
