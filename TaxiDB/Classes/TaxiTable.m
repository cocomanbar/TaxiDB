//
//  TaxiTable.m
//  TaxiDB
//
//  Created by tanxl on 2023/1/31.
//

#import "TaxiTable.h"
#import "TaxiTable+TaxiDB.h"

@interface TaxiTable ()

@property (nonatomic, weak, readwrite) TaxiDatabase *dataBase;

@end

@implementation TaxiTable

- (instancetype)initWithDatabase:(TaxiDatabase *)dataBase {
    self = [super init];
    if (self) {
        self.dataBase = dataBase;
    }
    return self;
}

- (NSArray <TaxiField *>*)liteFields {
    return nil;
}

- (NSArray <TaxiField *>*)liteAlertFields {
    return nil;
}


// 升级新增的字段
- (void)alertTableIfItNeeded {
    
    NSArray<TaxiField *> *liteAlertFields = [self liteAlertFields];
    
    if (!liteAlertFields || liteAlertFields.count == 0) {
        return;
    }
    
    /**
    {
         cid = 1;
         name = "user_avatar";
         notnull = 0;
         pk = 0;
         type = TEXT;
     }
     */
    
    TaxiStatement *statement = [self pragmaTableSQL];
    
    NSArray <NSDictionary *>*array = [self.dataBase executeQueryStatement:statement];
    
    if (!array || array.count == 0) {
        NSLog(@"查询不到表内的字段信息。");
        return;
    }
    
    for (TaxiField *field in liteAlertFields) {
        
        if (field.name.length == 0 || field.fieldType.length == 0) {
            NSLog(@"字段不规范。");
            continue;
        }
        
        BOOL existField = false;
        
        for (NSDictionary *pragma in array) {
            NSString *name = [pragma objectForKey:@"name"];
            if ([field.name isEqualToString:name]) {
                existField = true;
                break;
            }
        }
        
        if (existField) {
            continue;
        }
        
        TaxiStatement *statement = [self alterNewFieldSQL:field];
        
        BOOL ret = [self.dataBase executeUpdateStatement:statement];
        
        if (!ret) {
            NSLog(@"新增字段异常。%@", self.name);
        }
    }
}

// 清空表
- (void)deleteTableIfItNeeded {
    
    TaxiStatement *statement = [self deleteTableSQL];
    BOOL ret = [self.dataBase executeUpdateStatement:statement];
    if (!ret) {
        NSLog(@"清表异常。%@", self.name);
    }
}

@end
