//
//  UserModel.h
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger age;

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
