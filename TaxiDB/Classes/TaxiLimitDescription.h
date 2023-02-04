//
//  TaxiLimitDescription.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaxiLimitDescription : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, copy, readonly, nullable) NSString *sql;

- (instancetype)initWithSql:(NSString * _Nullable)sql;

@end

NS_ASSUME_NONNULL_END
