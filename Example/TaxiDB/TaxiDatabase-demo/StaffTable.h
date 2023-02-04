//
//  StaffTable.h
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//

#import <TaxiDB/TaxiTable.h>
#import "StaffModel.h"
#import "UserTable.h"  // 联表查询

NS_ASSUME_NONNULL_BEGIN

@interface StaffTable : TaxiTable

- (instancetype)initWithDatabase:(TaxiDatabase *)dataBase withUserTable:(UserTable *)userTable;

@end

NS_ASSUME_NONNULL_END
