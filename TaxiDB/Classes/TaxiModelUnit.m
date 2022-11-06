//
//  TaxiModelUnit.m
//  TaxiDB
//
//  Created by tanxl on 2022/11/6.
//

#import "TaxiModelUnit.h"
#import <objc/runtime.h>
#import "TaxiRootTableUnit.h"
#import "TaxiDB+Sqlite.h"
#import "TaxiDBModelProtocol.h"
#import "TaxiDBUpdateProtocol.h"

@implementation TaxiModelUnit

#pragma mark - 操作对象方向相关

/// 检查是否遵守协议
FOUNDATION_EXTERN_INLINE BOOL modelUnitJoinProtocolForClass(Class cls){
    if (![cls conformsToProtocol:@protocol(TaxiDBModelProtocol)]) {
        NSCAssert(NO, @"未遵守相关协议..");
        return NO;
    }
    return YES;
}

/// 获取模型内参与数据库建设的字段名和字段类型
FOUNDATION_EXTERN_INLINE NSDictionary *modelUnitIvarNameForClass(Class cls){
    modelUnitJoinProtocolForClass(cls);
    NSArray *allowPropertys = nil;
    if ([cls performSelector:@selector(taxidb_allowedJoinSqliteKeyFromPreviousVersion:)]) {
        NSInteger version = rootTableTableVersionFromCls(cls);
        allowPropertys = [cls taxidb_allowedJoinSqliteKeyFromPreviousVersion:version];
    }
    if (!allowPropertys || !allowPropertys.count) {
        NSCAssert(NO, @"该模型未设置到参与数据库建设的字段，属于无效表..");
        return [NSDictionary dictionary];
    }
    
    NSMutableDictionary *nameTypeDictionary = [NSMutableDictionary dictionary];
    /// 1.获取所有的成员变量
    unsigned int  outCount = 0;
    Ivar *varList = class_copyIvarList(cls, &outCount);
    
    for (int i=0; i<outCount; ++i) {
        
        Ivar ivar = varList[i];
        /// 2.获取成员变量名字
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        /**
         "_studentAge" = i;
         "_studentName" = "@\"NSString\"";
         "_studentNumber" = i;
         "_studentScore" = f;
         */
        if ([ivarName hasPrefix:@"_"]) {
            /// 把 _ 去掉，读取后面的
            ivarName = [ivarName substringFromIndex:1];
        }
        
        /// 3、查看有没有忽略字段，如果有就不去创建
        if (![allowPropertys containsObject:ivarName]) {
            continue;
        }
        
        /// 4.获取成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        /// 把包含 @\" 的去掉，如 "@\"NSString\"";-> NSString
        ivarType = [ivarType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        
        /// 5.成员变量的类型可能重复，成员变量的名字不会重复，所以以成员变量的名字为key
        [nameTypeDictionary setValue:ivarType forKey:ivarName];
    }
    
    return nameTypeDictionary;
}

/// 获取模型内参与数据库建设的字段名和(字段类型->转化到数据库类型)
FOUNDATION_EXTERN_INLINE NSDictionary *modelUnitIvarNameSetSqliteForClass(Class cls){
    
    NSMutableDictionary *dict = [modelUnitIvarNameForClass(cls) mutableCopy];
    NSDictionary *typeDict = unitModelIvarNamesWitchOCTypeToSqliteType();
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        
        NSString *sqliteKey = typeDict[obj];
        if (!sqliteKey) {
            NSCAssert(NO, @"遇到了新的类型，请查看获取属性实现函数..");
        }
        dict[key] = typeDict[obj];
    }];
    return dict;
}

/// 获取模型内参与数据库建设的字段名
FOUNDATION_EXTERN_INLINE NSArray *modelUnitSetSqlitePropertiesForClass(Class cls){
    NSDictionary *dict = modelUnitIvarNameForClass(cls);
    NSArray *properties = dict.allKeys;
    properties = [properties sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return properties.copy;
}

/// 通过查询sql获取字典数组后，通过此方式转化为对应的模型数组
FOUNDATION_EXTERN_INLINE NSArray *modelUnitParseResultsForSqlSearch(NSArray <NSDictionary *>*maps, Class cls){
    
    /// 1. 安全检查
    if (!maps || !maps.count) {
        return [NSArray array];
    }
    
    /// 2.属性名称 -> 类型 dic
    NSDictionary *nameTypeDic = modelUnitIvarNameForClass(cls);
    
    /// 3.处理查询的结果集 -> 模型数组
    NSMutableArray *models = [NSMutableArray array];
    
    for (NSDictionary *modelDic in maps) {
        id model = [[cls alloc] init];
        [models addObject:model];
        
        /// 4.遍历赋值
        [modelDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *type = nameTypeDic[key];
            id resultValue = obj;
            
            /// 拦截集合形式
            if (resultValue) {
                if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSDictionary"]) {
                    NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                    resultValue = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    
                }else if ([type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSMutableDictionary"]){
                    NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                    resultValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                }
            }
            
            /// 4.1 安全检查
            if (key && resultValue) {
                [model setValue:resultValue forKey:key];
            }
        }];
    }
    return models;
}

#pragma mark - Private

FOUNDATION_STATIC_INLINE NSDictionary *unitModelIvarNamesWitchOCTypeToSqliteType(){
    
    NSDictionary *dict = @{
        @"d": @"real",          // double
        @"f": @"real",          // float
        
        @"i": @"integer",       // int
        @"q": @"integer",       // long
        @"Q": @"integer",       // long long
        @"B": @"integer",       // bool
        
        @"NSString": @"text",   // text
        
        @"NSData": @"blob",     // 二进制
        @"NSDictionary": @"text",           // text
        @"NSMutableDictionary": @"text",    // text
        @"NSArray": @"text",                // text
        @"NSMutableArray": @"text"          // text
    };
    return dict;
}

@end
