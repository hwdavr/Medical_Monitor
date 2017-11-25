//
//  ControlViewController.m
//  MedicalMonitor
//
//  Created by Weidian on 9/9/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import "ControlViewController.h"
#import "AWSIoT.h"
#import "Constants.h"

@interface ControlViewController () {
NSInteger ctrlState;
}

@property (weak, nonatomic) IBOutlet UIButton *btnControl;
@property (weak, nonatomic) IBOutlet UIImageView *signImage;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg;

@end

@implementation ControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *msg = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_NOTIFY_MESSAGE];
    if (msg != nil) {
        [_lblMsg setText:msg];
    } else {
        [_lblMsg setText:@"Everything is fine for the patient"];
    }
    ctrlState = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_CTRL_STATE];
    _btnControl.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [self setCtrlState:ctrlState];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iotNotification:) name:NOTICE_IOT_NOTIFICATION object:nil];
}

- (void)iotNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) return;
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    if (apsInfo == nil) return;
    NSString *msg = [apsInfo objectForKey:@"alert"];
    if (msg != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:msg forKey:KEY_NOTIFY_MESSAGE];
        [_lblMsg setText:msg];
        if ([msg containsString:@"emergency"]) {
            //emergency case
            [self setCtrlState:2];
        } else if ([msg containsString:@"WARNING"]) {
            //Warning case
            [self setCtrlState:1];
        }
        NSArray* histories0 = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_HISTORY];
        NSMutableArray* histories;
        if (histories0 == nil) {
            histories = [[NSMutableArray alloc] init];
        } else {
            histories = [[NSMutableArray alloc]initWithArray:histories0];
        }
        [histories insertObject:msg atIndex:0];
        [[NSUserDefaults standardUserDefaults]setObject:histories forKey:KEY_HISTORY];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCtrlState:(NSInteger)state {
    // 0: OK
    // 1: Warning
    // 2: Alert
    if (state == 0) {
        [_btnControl setBackgroundColor:[UIColor colorWithRed:70.0f/255 green:200.0f/255 blue:180.0f/255 alpha:1]];
        [_btnControl setTitle:@"OK" forState:UIControlStateNormal];
        [_signImage setImage:[UIImage imageNamed:@"iconOK"]];
    } else if (state == 1) {
        [_btnControl setBackgroundColor:[UIColor colorWithRed:238.0f/255 green:187.0f/255 blue:0 alpha:1]];
        [_btnControl setTitle:@"NOTED" forState:UIControlStateNormal];
        [_signImage setImage:[UIImage imageNamed:@"iconWarn"]];
    } else if (state == 2) {
        [_btnControl setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0.2f alpha:1]];
        [_btnControl setTitle:@"ACCEPT" forState:UIControlStateNormal];
        [_signImage setImage:[UIImage imageNamed:@"iconSOS"]];
    }
    ctrlState = state;
    [[NSUserDefaults standardUserDefaults]setInteger:state forKey:KEY_CTRL_STATE];
}

#pragma mark - Actions
- (IBAction)btnControlAction:(id)sender {
//    ctrlState++;
//    if (ctrlState > 2) {
//        ctrlState = 0;
//    }
//    [self setCtrlState:ctrlState];
    if (ctrlState == 1) {
        [self setCtrlState:0];
    } else if (ctrlState == 2) {
        AWSIoTDataManager *iotDataMgr = AWSIoTDataManager.defaultIoTDataManager;
        [iotDataMgr publishString:@"{}" onTopic:@"alert/reset" QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce];
        [self setCtrlState:0];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
