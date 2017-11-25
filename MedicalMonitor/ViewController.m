//
//  ViewController.m
//  MedicalMonitor
//
//  Created by Weidian on 5/8/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import "ViewController.h"
#import "MedicalMonitor-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

MMIoTManager *iotMgr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [_lblStatus setText:@"Connecting"];
    iotMgr = [[MMIoTManager alloc] init];
    iotMgr.lblStatus = _lblStatus;
    [iotMgr initIoT];
    [iotMgr connect];
    [iotMgr subscribe];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)publishData:(id)sender {
    [iotMgr publishWithData:@"User ID"];
}

@end
