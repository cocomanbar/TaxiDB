//
//  UserInfoDataBase.m
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//

#import "UserInfoDataBase.h"

@interface UserInfoDataBase ()

@property (nonatomic, strong, readwrite) UserTable *userTable;
@property (nonatomic, strong, readwrite) StaffTable *staffTable;

@end

@implementation UserInfoDataBase

- (NSArray<TaxiTable *> *)allTables {
    return @[
        self.userTable
    ];
}


#pragma mark -

- (StaffTable *)staffTable {
    if (!_staffTable) {
        _staffTable = [[StaffTable alloc] initWithDatabase:self withUserTable:self.userTable];
    }
    return _staffTable;
}

- (UserTable *)userTable {
    if (!_userTable) {
        _userTable = [[UserTable alloc] initWithDatabase:self];
    }
    return _userTable;
}

@end
