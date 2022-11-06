//
//  TaxiDBViewController.m
//  TaxiDB_Example
//
//  Created by tanxl on 2022/11/5.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "TaxiDBViewController.h"
#import "TaxiUpdateVersionViewController.h"
#import <TaxiDB/Taxi.h>
#import "TaxiModel.h"

@interface TaxiDBViewController ()

@end

@implementation TaxiDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 清除测试记录
    NSLog(@"==> %@", NSHomeDirectory());
    NSString *path = [NSString stringWithFormat:@"%@/Caches/TaxiDB", NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    // 新建测试记录
    [TAXIDB bindingUid:@"656553"];
    
}

static int numberCount = 100;

- (IBAction)create:(UIButton *)sender {
    
    
}

- (IBAction)insert:(UIButton *)sender {
    
    NSInteger numberC = numberCount;
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:numberC];
    for (int i = 0; i < numberC; i++) {
        TaxiModel *model = [TaxiModel new];
        model.testId = [NSString stringWithFormat:@"testId_%d", i];
        model.name = [NSString stringWithFormat:@"name_%d", i];
        model.count = i;
        model.address = nil;
        model.links_arr = @[@(i)];
        
//        TaxiModel *model1 = [TaxiModel new];
//        model1.testId = [NSString stringWithFormat:@"testId_%d", i];
//        model1.name = [NSString stringWithFormat:@"name_%d", i];
//        model.links_arr_m = @[model1].mutableCopy;
        
        model.links_map = @{@"1":@"2"};
        model.links_map_m = @{@"1":@"2"}.mutableCopy;
        
        [models addObject:model];
    }
    
    double count = [TAXIDB runtimeForBlock:^{
        [TAXIDB insertModels:models];
    }];
    NSLog(@"平均每个数据插入耗时：%f ms", count / numberC);
}

- (IBAction)search:(UIButton *)sender {
    
    NSInteger testCount = numberCount;
    double count = [TAXIDB runtimeForBlock:^{
        for (int i = 0; i < testCount; i++) {
            NSInteger num = random()%testCount;
            NSString *condition = [NSString stringWithFormat:@"testId = \"testId_%ld\" and name = \"name_%ld\"", num, num];
            NSArray  *arr = [TAXIDB queryModels:TaxiModel.class where:condition];
            NSLog(@"q1==> %@", [arr.firstObject testId]);
        }
    }];
    NSLog(@"平均每个数据查询耗时：%f ms", count / testCount);
}

- (IBAction)searchAll:(UIButton *)sender {
    
    NSInteger testCount = 100;
    dispatch_queue_t q1 = dispatch_queue_create(@"threadSafeTest1".UTF8String, DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t q2 = dispatch_queue_create(@"threadSafeTest2".UTF8String, DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t q3 = dispatch_queue_create(@"threadSafeTest3".UTF8String, DISPATCH_QUEUE_SERIAL);

    for (int i =0; i< testCount; i++) {
        dispatch_async(q1, ^{
            NSInteger num = random()%numberCount;
            NSString *condition = [NSString stringWithFormat:@"testId = \"testId_%ld\" and name = \"name_%ld\"", num, num];
            NSArray  *arr = [TAXIDB queryModels:TaxiModel.class where:condition];
            NSLog(@"q1==> %@", [arr.firstObject testId]);
        });
        dispatch_async(q2, ^{
            NSInteger num = random()%numberCount;
            NSString *condition = [NSString stringWithFormat:@"testId = \"testId_%ld\" and name = \"name_%ld\"", num, num];
            NSArray  *arr = [TAXIDB queryModels:TaxiModel.class where:condition];
            NSLog(@"q2==> %@", [arr.firstObject testId]);
        });
        dispatch_async(q3, ^{
            NSInteger num = random()%numberCount;
            NSString *condition = [NSString stringWithFormat:@"testId = \"testId_%ld\" and name = \"name_%ld\"", num, num];
            NSArray  *arr = [TAXIDB queryModels:TaxiModel.class where:condition];
            NSLog(@"q3==> %@", [arr.firstObject testId]);
        });
    }
}

- (IBAction)update:(UIButton *)sender {
    
    
}

- (IBAction)updateAll:(UIButton *)sender {
    
    
}

- (IBAction)delete:(UIButton *)sender {
    
    
}

- (IBAction)deleteAll:(UIButton *)sender {
    
    [self.navigationController pushViewController:[TaxiUpdateVersionViewController new] animated:YES];
}

@end
