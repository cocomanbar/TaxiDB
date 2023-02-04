//
//  TaxiDatabaseViewController.m
//  TaxiDB_Example
//
//  Created by tanxl on 2023/1/31.
//  Copyright © 2023 cocomanbar. All rights reserved.
//

#import "TaxiDatabaseViewController.h"
#import "UserInfoDataBase.h"
#import "UserModel.h"

@interface TaxiDatabaseViewController ()

@property (nonatomic, strong) UserInfoDataBase *dataBase;

@end

@implementation TaxiDatabaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.orangeColor;
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [@"UserDB" stringByAppendingPathExtension:@"sqlite"];
    fileName = [docPath stringByAppendingPathComponent:fileName];
    self.dataBase = [[UserInfoDataBase alloc] initWithPath:fileName];
    NSLog(@"%@", docPath);
    
    /// 需要开发者在操作数据库时管理数据库的开启和关闭
    [self.dataBase open];
    [self.dataBase createTablesIfNotExists];
    [self.dataBase.userTable alertTableIfItNeeded];
    
    /// 页面销毁时关闭 `dealloc`
//    [self.dataBase close];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    self.dataBase.traceExecution = true;
    self.dataBase.shouldCacheLanes = true;
    
    UserModel *model = [[UserModel alloc] init];
    model.age = 18;
    model.uid = 12;
    model.name = @"哈哈";
    model.avatar = @"httpg";
    model.phone = @"152525154585959";
    [self.dataBase.userTable insertUserIfItNeeded:model];
    
}

- (void)dealloc {
    
    if(_dataBase) {
        [_dataBase close];
    }
}

@end
