//
//  UserInfoDataBase.h
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//

#import <TaxiDB/TaxiDatabase.h>
#import "UserTable.h"
#import "StaffTable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  database
 */
@interface UserInfoDataBase : TaxiDatabase

// user table
@property (nonatomic, strong, readonly) UserTable *userTable;

// staff table
@property (nonatomic, strong, readonly) StaffTable *staffTable;

@end

NS_ASSUME_NONNULL_END
