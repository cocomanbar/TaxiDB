//
//  tomato.h
//  TaxiDB_Example
//
//  Created by tanxl on 2022/11/7.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, tomatoType){
    tomatoTypeMoving = 0,
    tomatoTypeStop = 1,
    tomatoTypeMoved = 2,
};

@interface tomato : NSObject

@property (copy, nonatomic) NSString *itemId;
@property (copy, nonatomic) NSString *itemObject;
@property (copy, nonatomic) NSString *createdTime;
@property (nonatomic, assign) NSInteger number;

@property (nonatomic, assign)tomatoType tomatoTypeStatus;

@end

NS_ASSUME_NONNULL_END
