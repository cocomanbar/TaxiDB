//
//  TaxiTable+TaxiDB.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiTable+TaxiDB.h"
#import "NSObject+TaxiDB.h"
#import "TaxiField.h"

@implementation TaxiTable (TaxiDB)

#pragma mark - SQL select

- (TaxiStatement *)selectAllColumnFromTable {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    statement.sql = [NSString stringWithFormat:@"select * from %@", self.name];
    return statement;
}

- (TaxiStatement *)selectColumnsWithWhere:(TaxiWhereDescription * _Nullable)whereDescriptor {
    
    return [self selectColumnsWithWhere:whereDescriptor withOrder:nil withLimit:nil];
}

- (TaxiStatement *)selectColumnsWithWhere:(TaxiWhereDescription * _Nullable)whereDescriptor
                                withOrder:(TaxiOrderDescription * _Nullable)orderDescriptor {
    
    return [self selectColumnsWithWhere:whereDescriptor withOrder:orderDescriptor withLimit:nil];
}

- (TaxiStatement *)selectColumnsWithWhere:(TaxiWhereDescription * _Nullable)whereDescriptor
                                withOrder:(TaxiOrderDescription * _Nullable)orderDescriptor
                                withLimit:(TaxiLimitDescription * _Nullable)limitDescriptor {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    
    if (!whereDescriptor || whereDescriptor.sql.length == 0) {
        return statement;
    }
    
    // SELECT * FROM Orders WHERE Id=6 ORDER BY Price DESC
    NSString *sql;
    NSMutableArray *values = [NSMutableArray array];
    if (whereDescriptor.values) {
        [values addObjectsFromArray:whereDescriptor.values];
    }
    
    sql = [NSString stringWithFormat:@"select * from %@ %@", self.name, whereDescriptor.sql];
    
    if (orderDescriptor.sql.length > 0) {
        sql = [NSString stringWithFormat:@"%@ %@", sql, orderDescriptor.sql];
    }
    
    if (limitDescriptor.sql.length > 0) {
        sql = [NSString stringWithFormat:@"%@ %@", sql, limitDescriptor.sql];
    }
    
    statement.sql = sql;
    statement.values = [values copy];
    return statement;
}


#pragma mark - SQL replace

- (TaxiStatement *)replaceColumnWithValues:(NSDictionary<NSString *, id> * _Nullable)values {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    
    if (!values || values.count == 0) {
        return statement;
    }
    
    // 检查主键
    // 如果`values`未包含主键，经过测试当主键设置为`integer`类型时，数据也是能插入进去的，主键递增
    NSString *primaryKey;
    __block BOOL existPrimaryKey = false;
    for (TaxiField *field in self.liteFields) {
        if (field.primaryKey) {
            primaryKey = field.name;
            break;
        }
    }
    
    // replace into student (id, name, sex, email, fenshu, tecid) values ('2', 'lisi', '*F', '123456@qq.com', '80', '2');
    NSString *sql;
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *objs = [NSMutableArray array];
    NSMutableArray *symbols = [NSMutableArray array];
    [values enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [keys addObject:key];
        [objs addObject:obj];
        [symbols addObject:@"?"];
        
        if (!existPrimaryKey) {
            existPrimaryKey = [primaryKey isEqualToString:key];
        }
    }];
    
    if (!existPrimaryKey) {
        NSAssert(existPrimaryKey, @"not contain primary key.");
        return statement;
    }
    
    NSString *keyString = [keys componentsJoinedByString:@","];
    NSString *symbolString = [symbols componentsJoinedByString:@","];
    
    sql = [NSString stringWithFormat:@"replace into %@ (%@) values (%@)", self.name, keyString, symbolString];
    statement.sql = sql;
    statement.values = [objs copy];
    return statement;
}

#pragma mark - SQL update

- (TaxiStatement *)updateColumnWithValues:(NSDictionary<NSString *, id> * _Nullable)values
                                   andWhere:(TaxiWhereDescription * _Nullable)whereDescriptor {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    
    if (!values || values.count == 0) {
        return statement;
    }
    if (!whereDescriptor || whereDescriptor.sql.length == 0) {
        return statement;
    }
    
    // UPDATE table_name SET column1 = value1, column2 = value2...., columnN = valueN WHERE [condition];
    // UPDATE company SET address = 'Texas', address1 = 'Texas1' WHERE id = 6
    NSString *sql;
    NSMutableArray *columns = [NSMutableArray array];
    NSMutableArray *objs = [NSMutableArray array];
    [values enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [columns addObject:[NSString stringWithFormat:@"%@ = ?", key]];
        [objs addObject:obj];
    }];
    NSString *columnString = [columns componentsJoinedByString:@","];
    
    // where
    NSString *where = whereDescriptor.sql;
    if (whereDescriptor.values) {
        [objs addObjectsFromArray:whereDescriptor.values];
    }
    
    sql = [NSString stringWithFormat:@"update %@ set %@ %@", self.name, columnString, where];
    statement.sql = sql;
    statement.values = [objs copy];
    return statement;
}

#pragma mark - SQL insert

- (TaxiStatement *)insertColumnWithValues:(NSDictionary<NSString *, id> * _Nullable)values {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    
    if (!values || values.count == 0) {
        return statement;
    }
    
    // INSERT INTO COMPANY (id,name,age,address,salary) VALUES (?, ?, ?, ?, ?);
    NSString *sql;
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *objs = [NSMutableArray array];
    NSMutableArray *symbols = [NSMutableArray array];
    [values enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [keys addObject:key];
        [objs addObject:obj];
        [symbols addObject:@"?"];
    }];
    NSString *keyString = [keys componentsJoinedByString:@","];
    NSString *symbolString = [symbols componentsJoinedByString:@","];
    
    sql = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", self.name, keyString, symbolString];
    statement.sql = sql;
    statement.values = [objs copy];
    return statement;
}

#pragma mark - SQL delete

- (TaxiStatement *)deleteTableSQL {

    NSString *sql = [NSString stringWithFormat:@"delete table %@", self.name];
    return [[TaxiStatement alloc] initStatementWithSQL:sql];
}

// delete columns comfirmed by where
- (TaxiStatement *)deleteColumnWithWhere:(TaxiWhereDescription * _Nullable)whereDescriptor {
    
    whereDescriptor = whereDescriptor ?: [[TaxiWhereDescription alloc] initWithSql:nil];
    return [self deleteColumnWithWheres:@[whereDescriptor] connectType:TaxiConnectAND];
}

// delete columns comfirmed by where and where
- (TaxiStatement *)deleteColumnWithWheres:(NSArray<TaxiWhereDescription *> * _Nullable)whereDescriptors {
    
    return [self deleteColumnWithWheres:whereDescriptors connectType:TaxiConnectAND];
}

// delete columns comfirmed by where and/or where
- (TaxiStatement *)deleteColumnWithWheres:(NSArray<TaxiWhereDescription *> * _Nullable)whereDescriptors connectType:(TaxiConnect)connectType {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    
    if (!whereDescriptors || whereDescriptors.count == 0) {
        return statement;
    }
    
    // where %@ %@ ?
    // where name = 8 and where age = 8
    NSString *sql;
    NSString *operator = connectType == TaxiConnectAND ? @" and " : @" or ";
    NSMutableArray *sqls = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    for (TaxiWhereDescription *whereDesc in whereDescriptors) {
        if (!whereDesc.sql || whereDesc.sql.length == 0) {
            continue;
        }
        [sqls addObject:[whereDesc.sql copy]];
        if (whereDesc.values) {
            [values addObjectsFromArray:whereDesc.values];
        }
    }
    
    sql = [sqls componentsJoinedByString:operator];
    sql = [NSString stringWithFormat:@"delete from %@ %@", self.name, sql];
    statement.sql = sql;
    statement.values = values;
    return statement;
}

#pragma mark - SQL alert

- (TaxiStatement *)alterNewFieldSQL:(TaxiField *)field {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    
    if ([NSString isEmpty:self.name]) {
        NSLog(@"表名不能为空。");
        return statement;
    }
    
    if (field.name.length == 0 || field.fieldType.length == 0) {
        NSLog(@"字段不规范。");
        return statement;
    }
    
    NSString *fieldString = [NSString stringWithFormat:@"%@ %@", field.name, field.fieldType];
    statement.sql = [NSMutableString stringWithFormat:@"alter table %@ add %@", self.name, fieldString];
    return statement;
}


#pragma mark - SQL create

- (TaxiStatement *)createTableSQL {
    
    TaxiStatement *statement = [[TaxiStatement alloc] init];
    
    if ([NSString isEmpty:self.name]) {
        NSLog(@"表名不能为空。");
        return statement;
    }
    
    NSArray <TaxiField *>*fieldArray = [self.liteFields copy];
    if (!fieldArray || fieldArray.count == 0) {
        NSLog(@"不能创建空表。");
        return statement;
    }
    
    NSMutableArray<NSString *> *fieldStringArray = [NSMutableArray array];
    for (TaxiField *field in fieldArray) {
        if (field.name.length == 0 || field.fieldType.length == 0) {
            NSLog(@"字段不规范。");
            continue;
        }
        NSString *fieldString;
        if (field.primaryKey) {
            NSString *suffix;
            if (field.autoincrement) {
                suffix = @"primary key autoincrement not null";
            } else {
                suffix = @"primary key not null";
            }
            fieldString = [NSString stringWithFormat:@"%@ %@ %@", field.name, field.fieldType, suffix];
        } else {
            fieldString = [NSString stringWithFormat:@"%@ %@", field.name, field.fieldType];
        }
        [fieldStringArray addObject:fieldString];
    }
    
    NSString *fieldString = [fieldStringArray componentsJoinedByString:@", "];
    statement.sql = [NSMutableString stringWithFormat:@"create table if not exists %@(%@)", self.name, fieldString];
    return statement;
}


#pragma mark - SQL pragma

- (TaxiStatement *)pragmaTableSQL {
    
    // pragma table info
    NSString *sql = [NSString stringWithFormat:@"pragma table_info('%@')", self.name];
    return [[TaxiStatement alloc] initStatementWithSQL:sql];
}

@end
