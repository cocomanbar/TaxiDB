//
//  TaxiWhereDescription.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiWhereDescription.h"

@interface TaxiWhereDescription ()

@property (nonatomic, copy, readwrite) NSString *sql;
@property (nonatomic, copy, readwrite) NSArray <id>*values;

@end

@implementation TaxiWhereDescription

- (instancetype)initWithSql:(NSString * _Nullable)sql {
    return [self initWithSql:sql values:nil];
}

- (instancetype)initWithSql:(NSString * _Nullable)sql values:(NSArray <id>* _Nullable)values {
    self = [super init];
    if (self) {
        
        if (sql) {
            
            _sql = sql;
            _values = [values copy];
        }
    }
    return self;
}

- (instancetype)initWithName:(NSString * _Nullable)name value:(id _Nullable)value compareDesc:(TaxiWhereDesc)compareDesc{
    self = [super init];
    if (self) {
        
        if (name && value) {
            
            NSString *desc  = [self whereOperationDescription:compareDesc];
            _sql = [NSString stringWithFormat:@"where %@ %@ ?", name, desc];
            _values = @[value];
        }
    }
    return self;
}


- (NSString * _Nullable)whereOperationDescription:(TaxiWhereDesc)compareDesc {
    NSString *operation;
    switch (compareDesc) {
        case TaxiWhereDescEquelTo:
            operation = @"==";
            break;
        case TaxiWhereDescLessThan:
            operation = @"<";
            break;
        case TaxiWhereDescLessThanOrEquelTo:
            operation = @"<=";
            break;
        case TaxiWhereDescNotEquelTo:
            operation = @"!=";
            break;
        case TaxiWhereDescGreaterThan:
            operation = @">";
            break;
        case TaxiWhereDescGreaterThanOrEquelTo:
            operation = @">=";
            break;
        case TaxiWhereDescLike:
            operation = @"LIKE";
            break;
        default:
            break;
    }
    return operation;
}

@end
