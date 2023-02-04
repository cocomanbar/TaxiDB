//
//  TaxiField.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiField.h"

@interface TaxiField ()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) TaxiFieldType fieldType;

@end

@implementation TaxiField

+ (instancetype)fieldWithName:(NSString *)name fieldType:(TaxiFieldType)fieldType {
    
    return [[self alloc] initWithName:name fieldType:fieldType];
}

- (instancetype)initWithName:(NSString *)name fieldType:(TaxiFieldType)fieldType {
    
    self = [super init];
    if (self) {
        self.name = name;
        self.fieldType = fieldType;
    }
    return self;
}

- (BOOL)autoincrement {
    if (!_primaryKey) {
        return false;
    }
    if (![_fieldType isEqualToString:TaxiFieldTypeInteger]) {
        return false;
    }
    return _autoincrement;
}

@end
