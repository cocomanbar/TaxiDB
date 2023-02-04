//
//  UserTable.m
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//

#import "UserTable.h"
#import <TaxiDB/TaxiDB.h>
#import <Masonry.h>

@interface UserTable ()

@property (nonatomic, strong) TaxiField *nameField;
@property (nonatomic, strong) TaxiField *avatarField;
@property (nonatomic, strong) TaxiField *ageField;
@property (nonatomic, strong) TaxiField *uidField;
// v1.0.1新增
@property (nonatomic, strong) TaxiField *phoneField;

@end

@implementation UserTable

- (instancetype)initWithDatabase:(TaxiDatabase * _Nullable)dataBase {
    self = [super initWithDatabase:dataBase];
    if (self) {
        
        self.name = @"user";
        
        self.nameField = [[TaxiField alloc] initWithName:@"user_name" fieldType:(TaxiFieldTypeText)];
        self.avatarField = [[TaxiField alloc] initWithName:@"user_avatar" fieldType:(TaxiFieldTypeText)];
        self.ageField = [[TaxiField alloc] initWithName:@"user_age" fieldType:(TaxiFieldTypeInteger)];
        self.uidField = [[TaxiField alloc] initWithName:@"user_uid" fieldType:(TaxiFieldTypeInteger)];
        self.uidField.primaryKey = true;
        
        // v1.0.1新增
        self.phoneField = [[TaxiField alloc] initWithName:@"user_phone" fieldType:(TaxiFieldTypeText)];
    }
    return self;
}

- (NSArray<TaxiField *> *)liteFields {
    return @[
        self.nameField,
        self.avatarField,
        self.ageField,
        self.uidField,
        // v1.0.1新增
        self.phoneField,
    ];
}

- (NSArray<TaxiField *> *)liteAlertFields {
    return @[
        // v1.0.1新增
        self.phoneField,
    ];
}

#pragma mark - Business

- (BOOL)insertUserIfItNeeded:(UserModel *)model {
    
    TaxiStatement *statement;
    NSArray *array;
    BOOL ret = false;
    
    /*
     TODO..
     
     // select
     [statement makeTable:self toSelect:^(TaxiCondition * _Nonnull make) {
         make.whereField(self.uidField).taxi_equalTo(5);
         make.whereField(self.uidField).taxi_greaterThan(5);
         make.whereField(self.uidField).taxi_greaterThanOrEqualTo(5);
         make.whereField(self.uidField).taxi_lessThan(5);
         make.whereField(self.uidField).taxi_lessThanOrEqualTo(5);
         
         make.orderField(self.ageField).byASC();
         make.orderField(self.ageField).byDESC();
         
         make.limitCount(10);
         make.limitOffset(5,5);
         make.limitRange(5,5);
     }];
     
     // update
     [statement makeTable:self toUpdatee:^(TaxiCondition * _Nonnull make) {
         make.whereField(self.uidField).taxi_equalTo(5);
         
         make.updateFields(@[self.phoneField, self.nameField]).withValues(@[@12181148, @"1212121"]);
         make.updateField(self.phoneField).withValue(@123456789);
         make.updateField(self.nameField).withValue(@"name");
     }];
     
     // delete
     [statement makeTable:self toDelete:^(TaxiCondition * _Nonnull make) {
         make.whereField(self.uidField).taxi_equalTo(5);
         make.whereField(self.nameField).taxi_equalTo(@"haha");
     }];
     
     // replace
     [statement makeTable:self toReplace:^(TaxiCondition * _Nonnull make) {
         make.replaceField(self.uidField).withValue(@5);
         make.replaceField(self.phoneField).withValue(@123456);
         make.replaceField(self.nameField).withValue(@"123456");
         
         make.replaceFields(@[self.uidField, self.nameField, self.phoneField]).withValues(@[@5, @"12121", @123456786]);
     }];
     
     
     [statement makeTable:self toDelete:^(TaxiCondition * _Nonnull make) {
         // 写法一
         make.whereField(self.uidField).taxi_equalTo(59796);
         
         // 写法二 delete from table_name where uid = '59796'
         make.writeSql([NSString stringWithFormat:@"delete from table_name where %@ = '%d'", self.uidField.name, 59796]);
         
         // 写法三
         make.writeSql([NSString stringWithFormat:@"delete from table_name where %@ = ?", self.uidField.name]).withValue(@59796);
         make.writeSql([NSString stringWithFormat:@"delete from table_name where %@ = ?", self.uidField.name]).taxi_withValue(59796);
     }];
     */
    
    // 查询
    statement = [self selectColumnsWithWhere:[[TaxiWhereDescription alloc] initWithName:self.uidField.name value:@(model.uid) compareDesc:(TaxiWhereDescEquelTo)]];
    array = [self.dataBase executeQueryStatement:statement];
    
    if (array.count > 0) {
        
        // 删除
        statement = [self deleteColumnWithWhere:[[TaxiWhereDescription alloc] initWithName:self.uidField.name value:@(model.uid) compareDesc:(TaxiWhereDescEquelTo)]];
        ret = [self.dataBase executeUpdateStatement:statement];
        ret = ret;
    }
    
    // 替换
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict taxi_setObject:@(model.uid) forField:self.uidField];
//    [dict taxi_setObject:@(model.phone) forField:self.phoneField];
//    [dict taxi_setObject:@(model.age) forField:self.ageField];
    [dict taxi_setObject:model.name forField:self.nameField];
//    [dict taxi_setObject:model.avatar forField:self.avatarField];
    statement = [self replaceColumnWithValues:dict];
    ret = [self.dataBase executeUpdateStatement:statement];
    
    statement = [self selectColumnsWithWhere:[[TaxiWhereDescription alloc] initWithName:self.uidField.name value:@(model.uid) compareDesc:(TaxiWhereDescEquelTo)]];
    array = [self.dataBase executeQueryStatement:statement];
    
    // 更新
    dict = [NSMutableDictionary dictionary];
    [dict taxi_setObject:model.phone forField:self.phoneField];
    [dict taxi_setObject:@(model.age) forField:self.ageField];
    [dict taxi_setObject:model.name forField:self.nameField];
    [dict taxi_setObject:model.avatar forField:self.avatarField];
    statement = [self updateColumnWithValues:dict andWhere:[[TaxiWhereDescription alloc] initWithName:self.uidField.name value:@(model.uid) compareDesc:(TaxiWhereDescEquelTo)]];
    ret = [self.dataBase executeUpdateStatement:statement];
    
    return ret;
}

- (void)queryAll {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    statement.sql = [NSString stringWithFormat:@"select *from %@", self.name];
    NSArray *array = [self.dataBase executeQueryStatement:statement];
    if (array.count > 0) {
        NSLog(@"count - %ld", array.count);
    }
}


@end
