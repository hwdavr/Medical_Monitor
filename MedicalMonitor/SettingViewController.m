//
//  RangeViewController.m
//  MedicalMonitor
//
//  Created by Weidian on 9/9/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import "SettingViewController.h"
#import "AWSIoT.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tvMax;
@property (weak, nonatomic) IBOutlet UITextField *tvMin;

@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_tvMax setText:[NSString stringWithFormat:@"%@", _maxVal]];
    [_tvMin setText:[NSString stringWithFormat:@"%@", _minVal]];
    
    AWSIoTDataManager *iotDataMgr = AWSIoTDataManager.defaultIoTDataManager;
    [iotDataMgr subscribeToTopic:@"get/response" QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce messageCallback:^(NSData *payload) {
        NSError *error;
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:payload options:0 error:&error];
        if (jsonDict != nil) {
            NSNumber *status = jsonDict[@"status"];
            NSNumber *min = jsonDict[@"min"];
            NSNumber *max = jsonDict[@"max"];
            if ([status integerValue] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tvMax setText:[NSString stringWithFormat:@"%@", max]];
                    [_tvMin setText:[NSString stringWithFormat:@"%@", min]];
                });
            }
        }
    }];
    
    
    [self updateValues];
}

- (void)updateValues {
    AWSIoTDataManager *iotDataMgr = AWSIoTDataManager.defaultIoTDataManager;
    
    NSString *request = [NSString stringWithFormat:@"{\"client_id\":\"%@\"}", _channelNo];
    [iotDataMgr publishString:request onTopic:@"get/request" QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce];
}


- (IBAction)confirmChange:(id)sender {
    AWSIoTDataManager *iotDataMgr = AWSIoTDataManager.defaultIoTDataManager;
    
    NSNumber* min = [[NSNumber alloc] initWithFloat:[[_tvMin text] floatValue]];
    NSNumber* max = [[NSNumber alloc] initWithFloat:[[_tvMax text] floatValue]];
    NSString *request = [NSString stringWithFormat:@"{\"client_id\":\"%@\", \"min\":%@, \"max\":%@}", _channelNo, min, max];
    [iotDataMgr publishString:request onTopic:@"set/request" QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce];
    [self updateValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
