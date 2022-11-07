//
//  tomato+WCTTableCoding.h
//  TaxiDB_Example
//
//  Created by tanxl on 2022/11/7.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "tomato.h"
#import <WCDB/WCDB.h>


/**
 *  引入这个文件的类 .m => .mm
 *
 *      所以需要做隔离层
 *
 *      工程支持编译
 *          Setting - Other C++ Flags
 *              add '-fcxx-modules'
 */
NS_ASSUME_NONNULL_BEGIN

@interface tomato (WCTTableCoding)<WCTTableCoding>

WCDB_PROPERTY(itemId)
WCDB_PROPERTY(itemObject)
WCDB_PROPERTY(createdTime)

WCDB_PROPERTY(number)
WCDB_PROPERTY(tomatoTypeStatus)

@end

NS_ASSUME_NONNULL_END

/***** 头文件 *****/
//WCDB_PROPERTY宏在头文件声明需要绑定到数据库表的字段

/***** 类文件 *****/
//WCDB_SYNTHESIZE宏在类文件定义需要绑定到数据库表的字段。
//WCDB_IMPLEMENTATIO宏在类文件定义绑定到数据库表的类
//WCDB_PRIMARY用于定义主键
//WCDB_INDEX用于定义索引
//WCDB_UNIQUE用于定义唯一约束
//WCDB_NOT_NULL用于定义非空约束
