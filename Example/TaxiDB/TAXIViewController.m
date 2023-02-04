//
//  TAXIViewController.m
//  TaxiDB
//
//  Created by cocomanbar on 01/31/2023.
//  Copyright (c) 2023 cocomanbar. All rights reserved.
//

#import "TAXIViewController.h"
#import "TaxiDatabaseViewController.h"
#import "TaxiDatabaseQueueViewController.h"

@interface TAXIViewController ()

@end

@implementation TAXIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)goto_taxiDatabase_demo:(UIButton *)sender {
    
    [self.navigationController pushViewController:TaxiDatabaseViewController.new animated:YES];
}

- (IBAction)goto_taxiDatabaseQueue_demo:(UIButton *)sender {
    
    [self.navigationController pushViewController:TaxiDatabaseQueueViewController.new animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
