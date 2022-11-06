//
//  TaxiDB+MapPublic.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaxiDB (MapPublic)

#pragma mark -

/** 查询表 */
- (BOOL)existTable_:(NSString *)tableName;

/** 清空表 */
- (BOOL)cleanTable_:(NSString *)tableName;

/** 创建表 */
- (BOOL)createTable_:(NSString *)tableName modelMap_:(NSDictionary *)modelMap primaryKey_:(NSString *)primaryKey;

#pragma mark -

/** 插入数据, 存在相同主键数据不会执行更新 */
- (BOOL)insertModels_:(NSArray <NSDictionary *>*)models tableName_:(NSString *)tableName primaryKey_:(NSString *)primaryKey;

/** 更新数据, 不存在相同主键数据不会插入更新 */
- (BOOL)updateModels_:(NSArray <NSDictionary *>*)models tableName_:(NSString *)tableName primaryKey_:(NSString *)primaryKey;

/** 刷新数据, 存在相同主键数据会更新, 不存在相同主键的数据会插入 */
- (BOOL)initialModels_:(NSArray <NSDictionary *>*)models tableName_:(NSString *)tableName primaryKey_:(NSString *)primaryKey;

/** 根据主键信息删除对应的数据 */
- (BOOL)deleteModels_:(NSArray <NSDictionary *>*)models tableName_:(NSString *)tableName primaryKey_:(NSString *)primaryKey;

/** 根据主键信息删除对应的数据, where条件 */
- (BOOL)deleteModel_:(NSDictionary *)model tableName_:(NSString *)tableName where_:(NSString *)condition;

/** 查询整个表数据 */
- (NSArray <NSDictionary *>*)queryModels_:(NSString *)tableName;

/** 查询表数据, where条件 */
- (NSArray <NSDictionary *>*)queryModels_:(NSString *)tableName where_:(NSString *)condition;

@end

NS_ASSUME_NONNULL_END
