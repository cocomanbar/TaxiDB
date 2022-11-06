//
//  TaxiMapUnit.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaxiMapUnit : NSObject

NSString *mapUnitModelSqlForClass_(NSDictionary *map, NSString *primaryKey);

NSArray *mapUnitTableSqlitePropertiesForClass_(NSString *tableName);

@end

NS_ASSUME_NONNULL_END
