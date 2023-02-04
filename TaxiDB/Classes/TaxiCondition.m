//
//  TaxiCondition.m
//  TaxiDB
//
//  Created by tanxl on 2023/2/1.
//

#import "TaxiCondition.h"
#import "TaxiStatement.h"
#import "NSObject+TaxiDB.h"
#import "TaxiTable+TaxiDB.h"

@interface TaxiCondition ()

@property (nonatomic, assign) TaxiTask taskType;
@property (nonatomic, assign) TaxiConnect connectType;

@property (nonatomic, weak) TaxiTable *table;
@property (nonatomic, weak) TaxiStatement *statement;

@property (nonatomic, strong) NSMutableArray *whereFieldArray;
@property (nonatomic, strong) NSMutableArray *orderFieldArray;
@property (nonatomic, strong) NSMutableArray *updateFieldArray;
@property (nonatomic, strong) NSMutableArray *deleteFieldArray;
@property (nonatomic, strong) NSMutableArray *insertFieldArray;
@property (nonatomic, strong) NSMutableArray *replaceFieldArray;

@property (nonatomic, strong) NSMutableArray *fieldValues;
@property (nonatomic, strong) NSMutableArray *orderValues;
@property (nonatomic, strong) NSMutableArray *limitValues;

@property (nonatomic, strong) NSMutableString *sql;

@end

@implementation TaxiCondition

- (void)prepareTable:(TaxiTable *)table executeTask:(TaxiTask)taskType buildStatement:(TaxiStatement *)statement {
    NSAssert([table isKindOfClass:TaxiTable.class], @"Error.");
    self.table = table;
    self.taskType = taskType;
    self.statement = statement;
}

#pragma mark - pack sql

- (TaxiCondition * (^)(TaxiField *field))whereField {
    return ^id(TaxiField *field){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([field isKindOfClass:TaxiField.class], @"Error.");
        
        if (self.sql.length > 0) {
            [self.sql appendString:@" "];
        }
        [self.sql appendFormat:@"where %@", field.name];
        
        self.statement.sql = [self.sql copy];
        return self;
    };
}

- (TaxiCondition * (^)(TaxiField *field))updateField {
    return ^id(TaxiField *field){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([field isKindOfClass:TaxiField.class], @"Error.");
        
        
        return self;
    };
}

- (TaxiCondition * (^)(NSArray <TaxiField *>*fields))updateFields {
    return ^id(NSArray <TaxiField *>*fields){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([fields isKindOfClass:NSArray.class], @"Error.");
        
        [self.updateFieldArray taxi_addObjectsFromArray:fields];
        return self;
    };
}

- (TaxiCondition * (^)(TaxiField *field))replaceField {
    return ^id(TaxiField *field){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([field isKindOfClass:TaxiField.class], @"Error.");
        
        [self.replaceFieldArray taxi_addObject:field];
        return self;
    };
}

- (TaxiCondition * (^)(NSArray <TaxiField *>*fields))replaceFields {
    return ^id(NSArray <TaxiField *>*fields){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([fields isKindOfClass:NSArray.class], @"Error.");
        
        [self.replaceFieldArray taxi_addObjectsFromArray:fields];
        return self;
    };
}

- (TaxiCondition * (^)(TaxiField *field))insertField {
    return ^id(TaxiField *field){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([field isKindOfClass:TaxiField.class], @"Error.");
        
        [self.insertFieldArray taxi_addObject:field];
        return self;
    };
}

- (TaxiCondition * (^)(NSArray <TaxiField *>*field))insertFields {
    return ^id(NSArray <TaxiField *>*fields){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([fields isKindOfClass:NSArray.class], @"Error.");
        
        [self.insertFieldArray taxi_addObjectsFromArray:fields];
        return self;
    };
}

- (TaxiCondition * (^)(TaxiField *field))orderField {
    return ^id(TaxiField *field){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([field isKindOfClass:TaxiField.class], @"Error.");
        
        [self.orderFieldArray taxi_addObject:field];
        return self;
    };
}

- (TaxiCondition * (^)(void))byOR {
    return ^id(void){
        NSAssert(self.statement != nil, @"Error.");
        
        self.connectType = TaxiConnectOR;
        return self;
    };
}

- (TaxiCondition * (^)(void))byASC {
    return ^id(void){
        NSAssert(self.statement != nil, @"Error.");
        
        [self.orderValues taxi_addObject:@(TaxiOrderByASC)];
        return self;
    };
}

- (TaxiCondition * (^)(void))byDESC {
    return ^id(void){
        NSAssert(self.statement != nil, @"Error.");
        
        [self.orderValues taxi_addObject:@(TaxiOrderByDESC)];
        return self;
    };
}

- (TaxiCondition * (^)(id value))withValue {
    return ^id(id value){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert(value != nil, @"Error.");
        
        [self.fieldValues taxi_addObject:value];
        return self;
    };
}

- (TaxiCondition * (^)(NSArray *values))withValues {
    return ^id(NSArray *values){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert([values isKindOfClass:NSArray.class], @"Error.");
        
        [self.fieldValues taxi_addObjectsFromArray:values];
        return self;
    };
}

- (TaxiCondition * (^)(id value))equalTo {
    return ^id(id value){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert(value != nil, @"Error.");
        
        [self.fieldValues taxi_addObject:value];
        return self;
    };
}

- (TaxiCondition * (^)(id value))greaterThan {
    return ^id(id value){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert(value != nil, @"Error.");
        
        [self.fieldValues taxi_addObject:value];
        return self;
    };
}

- (TaxiCondition * (^)(id value))greaterThanOrEqualTo {
    return ^id(id value){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert(value != nil, @"Error.");
        
        [self.fieldValues taxi_addObject:value];
        return self;
    };
}

- (TaxiCondition * (^)(id value))lessThan {
    return ^id(id value){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert(value != nil, @"Error.");
        
        [self.fieldValues taxi_addObject:value];
        return self;
    };
}

- (TaxiCondition * (^)(id value))lessThanOrEqualTo {
    return ^id(id value){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert(value != nil, @"Error.");
        
        [self.fieldValues taxi_addObject:value];
        return self;
    };
}

- (TaxiCondition * (^)(NSInteger count))limitCount {
    return ^id(NSInteger count){
        NSAssert(self.statement != nil, @"Error.");
        
        [self.limitValues taxi_addObject:@(count)];
        return self;
    };
}

- (TaxiCondition * (^)(NSInteger count, NSInteger offset))limitOffset {
    return ^id(NSInteger count, NSInteger offset){
        NSAssert(self.statement != nil, @"Error.");
        
        [self.limitValues taxi_addObject:@(count)];
        [self.limitValues taxi_addObject:@(offset)];
        return self;
    };
}

- (TaxiCondition * (^)(NSInteger location, NSInteger length))limitRange {
    return ^id(NSInteger location, NSInteger length){
        NSAssert(self.statement != nil, @"Error.");
        
        [self.limitValues taxi_addObject:@(location)];
        [self.limitValues taxi_addObject:@(length)];
        return self;
    };
}

- (TaxiCondition * (^)(NSString *sql))writeSql {
    return ^id(NSString *sql){
        NSAssert(self.statement != nil, @"Error.");
        NSAssert(sql != nil, @"Error.");
        
        self.statement.sql = sql;
        return self;
    };
}

#pragma mark - pack sql

- (void)packSql {
    switch (self.taskType) {
        case TaxiTaskDelete:
        {
            //DELETE FROM table_name WHERE [condition];

        }
            break;
        case TaxiTaskUpdate:
        {
            //UPDATE table_name SET column1 = value1, column2 = value2...., columnN = valueN WHERE [condition];
            
        }
            break;
        case TaxiTaskSelect:
        {
            // SELECT * FROM table_name WHERE _ ORDER BY _ Limit
            
        }
            break;
        case TaxiTaskInsert:
        {
            //INSERT INTO TABLE_NAME [(column1, column2, column3,...columnN)] VALUES (value1, value2, value3,...valueN);
            
        }
            break;
        case TaxiTaskReplace:
        {
            
        }
            break;
        default:
            NSAssert(false, @"Error.");
            break;
    }
}

#pragma mark - Lazy

- (NSMutableString *)sql {
    if (!_sql) {
        _sql = [NSMutableString string];
    }
    return _sql;
}

- (NSMutableArray *)whereFieldArray{
    if (!_whereFieldArray) {
        _whereFieldArray = @[].mutableCopy;
    }
    return _whereFieldArray;
}

- (NSMutableArray *)orderFieldArray{
    if (!_orderFieldArray) {
        _orderFieldArray = @[].mutableCopy;
    }
    return _orderFieldArray;
}

- (NSMutableArray *)updateFieldArray{
    if (!_updateFieldArray) {
        _updateFieldArray = @[].mutableCopy;
    }
    return _updateFieldArray;
}

- (NSMutableArray *)deleteFieldArray{
    if (!_deleteFieldArray) {
        _deleteFieldArray = @[].mutableCopy;
    }
    return _deleteFieldArray;
}

- (NSMutableArray *)insertFieldArray{
    if (!_insertFieldArray) {
        _insertFieldArray = @[].mutableCopy;
    }
    return _insertFieldArray;
}

- (NSMutableArray *)replaceFieldArray{
    if (!_replaceFieldArray) {
        _replaceFieldArray = @[].mutableCopy;
    }
    return _replaceFieldArray;
}

- (NSMutableArray *)fieldValues{
    if (!_fieldValues) {
        _fieldValues = @[].mutableCopy;
    }
    return _fieldValues;
}

- (NSMutableArray *)limitValues{
    if (!_limitValues) {
        _limitValues = @[].mutableCopy;
    }
    return _limitValues;
}

- (NSMutableArray *)orderValues{
    if (!_orderValues) {
        _orderValues = @[].mutableCopy;
    }
    return _orderValues;
}

@end
