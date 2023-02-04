//
//  TaxiDatabaseQueueViewController.m
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//

#import "TaxiDatabaseQueueViewController.h"
#import "UserInfoDataBase.h"
#import "UserModel.h"
#import <TaxiDB/TaxiDatabaseQueue.h>

@interface TaxiDatabaseQueueViewController ()

@property (nonatomic, strong) TaxiDatabaseQueue<UserInfoDataBase *> *dataBaseQueue;

@end

@implementation TaxiDatabaseQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.orangeColor;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UserModel *model = [[UserModel alloc] init];
    model.age = 18;
    model.uid = 12;
    model.name = @"哈哈";
    model.avatar = @"httpg";
    model.phone = @"15252515458";
    [self.dataBaseQueue inTransaction:^(UserInfoDataBase * _Nonnull db, BOOL * _Nonnull rollback) {
        // do sth.
        
    }];
}



- (TaxiDatabaseQueue<UserInfoDataBase *> *)dataBaseQueue {
    if (!_dataBaseQueue) {
        
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSLog(@"%@", docPath);
        NSString *fileName = [@"UserQueueDB" stringByAppendingPathExtension:@"sqlite"];
        fileName = [docPath stringByAppendingPathComponent:fileName];
        UserInfoDataBase *dataBase = [[UserInfoDataBase alloc] initWithPath:fileName];
        _dataBaseQueue = [[TaxiDatabaseQueue alloc] initWithDataBase:dataBase];
        _dataBaseQueue.database.traceExecution = true;
        _dataBaseQueue.database.shouldCacheLanes = true;
    }
    return _dataBaseQueue;
}

- (void)dealloc {
    
    if (_dataBaseQueue) {
        [_dataBaseQueue close];
    }
}

@end
