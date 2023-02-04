//
//  TaxiOrderDescription.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaxiOrderBy){
    TaxiOrderByASC = 0,
    TaxiOrderByDESC,
};

@interface TaxiOrderDescription : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, copy, readonly, nullable) NSString *sql;

- (instancetype)initWithName:(NSString * _Nullable)name orderBy:(TaxiOrderBy)orderBy;

@end

NS_ASSUME_NONNULL_END
