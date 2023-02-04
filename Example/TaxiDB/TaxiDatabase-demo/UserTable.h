//
//  UserTable.h
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//


#import <TaxiDB/TaxiTable.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserTable : TaxiTable

- (BOOL)insertUserIfItNeeded:(UserModel *)model;

- (void)queryAll;

@end

NS_ASSUME_NONNULL_END
