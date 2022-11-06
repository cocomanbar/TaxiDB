//
//  TaxiModel.h
//  TaxiDB_Example
//
//  Created by tanxl on 2022/11/6.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaxiDB/TaxiDBModelProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaxiModel : NSObject
<TaxiDBModelProtocol>

@property (nonatomic, copy, nonnull) NSString *testId; // 主键

@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, strong, nullable) NSString *address;
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, copy, nullable) NSArray *links_arr;
@property (nonatomic, strong, nullable) NSMutableArray *links_arr_m;
@property (nonatomic, copy, nullable) NSDictionary *links_map;
@property (nonatomic, strong, nullable) NSMutableDictionary *links_map_m;

@end

NS_ASSUME_NONNULL_END
