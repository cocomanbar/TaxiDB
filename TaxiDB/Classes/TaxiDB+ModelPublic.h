//
//  TaxiDB+ModelPublic.h
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaxiDB (ModelPublic)

#pragma mark - 表操作相关

/// 检查是否存在该表
- (BOOL)existTable:(Class)cls;

/// 创建表信息，内部会检查
- (BOOL)createTable:(Class)cls;

/// 清空一个表数据
- (BOOL)cleanTable:(Class)cls;

/// 表需要更新
- (void)updateTable:(Class)cls;

#pragma mark - 模型操作

/**
 *  写入一组全新数据
 *
 *  1.组内数据类型一致, 不一致的将会被剔除
 *  2.遇到相同主键模型不会更新
 */
- (BOOL)insertModels:(NSArray <id>*)models;

/**
 *  更新一组数据
 *
 *  1.组内数据类型一致, 不一致的将会被剔除
 *  2.无对应主键模型的更新时,不会直接插入新数据
 */
- (BOOL)updateModels:(NSArray <id>*)models;

/**
 *  无条件插入或更新数据
 *
 *  1.不确定数据是否存在时，有主键数据更新，无主键数据插入
 */
- (BOOL)initialModels:(NSArray <id>*)models;

/**
 *  删除一组数据, 组内数据类型一致, 不一致的将会被剔除
 */
- (BOOL)deleteModels:(NSArray <id>*)models;

/**
 *  根据条件删除一个数据
 */
- (BOOL)deleteModel:(id)model where:(NSString *)condition;

/**
 *  查询表数据
 */
- (NSArray *)queryModels:(Class)cls;

/**
 *  根据条件查询表数据
 */
- (NSArray *)queryModels:(Class)cls where:(NSString *)condition;

@end

NS_ASSUME_NONNULL_END
