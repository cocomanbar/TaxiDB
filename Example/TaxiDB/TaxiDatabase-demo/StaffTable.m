//
//  StaffTable.m
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//

#import "StaffTable.h"
#import <TaxiDB/TaxiDB.h>

@interface StaffTable ()

@property (nonatomic, weak) UserTable *userTable;

@property (nonatomic, strong) TaxiField *uidField;
@property (nonatomic, strong) TaxiField *nameField;

@end

@implementation StaffTable

- (instancetype)initWithDatabase:(TaxiDatabase *)dataBase withUserTable:(UserTable *)userTable {
    self = [super initWithDatabase:dataBase];
    if (self) {
        
        self.name = @"staff";
        self.userTable = userTable;
        
        self.nameField = [[TaxiField alloc] initWithName:@"staff_name" fieldType:(TaxiFieldTypeText)];
        self.uidField = [[TaxiField alloc] initWithName:@"staff_uid" fieldType:(TaxiFieldTypeInteger)];
        self.uidField.primaryKey = true;
    }
    return self;
}

- (NSArray<TaxiField *> *)liteFields {
    return @[
        self.nameField,
        self.uidField,
    ];
}

#pragma mark - Business



@end
