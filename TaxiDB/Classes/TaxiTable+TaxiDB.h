//
//  TaxiTable+TaxiDB.h
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiTable.h"
#import "TaxiStatement.h"
#import "TaxiWhereDescription.h"
#import "TaxiOrderDescription.h"
#import "TaxiLimitDescription.h"

NS_ASSUME_NONNULL_BEGIN

@class TaxiField;

@interface TaxiTable (TaxiDB)

#pragma mark - SQL select

- (TaxiStatement * _Nonnull)selectAllColumnFromTable;

- (TaxiStatement * _Nonnull)selectColumnsWithWhere:(TaxiWhereDescription * _Nullable)whereDescriptor;

- (TaxiStatement * _Nonnull)selectColumnsWithWhere:(TaxiWhereDescription * _Nullable)whereDescriptor
                                         withOrder:(TaxiOrderDescription * _Nullable)orderDescriptor;

- (TaxiStatement * _Nonnull)selectColumnsWithWhere:(TaxiWhereDescription * _Nullable)whereDescriptor
                                         withOrder:(TaxiOrderDescription * _Nullable)orderDescriptor
                                         withLimit:(TaxiLimitDescription * _Nullable)limitDescriptor;

#pragma mark - SQL replace

- (TaxiStatement * _Nonnull)replaceColumnWithValues:(NSDictionary<NSString *, id> * _Nullable)values;


#pragma mark - SQL update

- (TaxiStatement * _Nonnull)updateColumnWithValues:(NSDictionary<NSString *, id> * _Nullable)values
                                          andWhere:(TaxiWhereDescription * _Nullable)whereDescriptor;


#pragma mark - SQL insert

- (TaxiStatement * _Nonnull)insertColumnWithValues:(NSDictionary<NSString *, id> * _Nullable)values;


#pragma mark - SQL delete

// delete table data
- (TaxiStatement * _Nonnull)deleteTableSQL;

// delete columns comfirmed by where
- (TaxiStatement * _Nonnull)deleteColumnWithWhere:(TaxiWhereDescription * _Nullable)whereDescriptor;

// delete columns comfirmed by where and where
- (TaxiStatement * _Nonnull)deleteColumnWithWheres:(NSArray<TaxiWhereDescription *> * _Nullable)whereDescriptors;

// delete columns comfirmed by where and/or where
- (TaxiStatement * _Nonnull)deleteColumnWithWheres:(NSArray<TaxiWhereDescription *> * _Nullable)whereDescriptors
                                       connectType:(TaxiConnect)connectType;

#pragma mark - SQL alert

// alert a new field
- (TaxiStatement * _Nonnull)alterNewFieldSQL:(TaxiField *)field;


#pragma mark - SQL create

// create a table
- (TaxiStatement * _Nonnull)createTableSQL;


#pragma mark - SQL pragma

// get all column info in table
- (TaxiStatement * _Nonnull)pragmaTableSQL;

@end

NS_ASSUME_NONNULL_END
