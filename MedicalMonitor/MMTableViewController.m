//
//  MMTableViewController.m
//  MedicalMonitor
//
//  Created by Weidian on 11/8/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import "MMTableViewController.h"
#import "MMTableViewCell.h"
#import "LineChartTimeViewController.h"
#import "AWSIoT.h"
#import "Crypto.h"
#import "ModelManager.h"

@interface MMTableViewController () {
NSArray *channels;
NSArray *channelNames;
NSArray *channelNo;
NSArray *chMinVal;
NSArray *chMaxVal;
NSArray *icons;
NSMutableArray *values;
}

@end

@implementation MMTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Monitor"];

    ModelManager *manager = [ModelManager new];
    [manager printMessage];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    channels = @[@"heart_rate", @"temperature", @"humidity", @"motion", @"vibration"];
    channelNames = @[@"Heart rate", @"Temperature 0", @"Humidity", @"Moving", @"Fell Down"];
    channelNo = @[@"0000000120", @"0000000130", @"0000000140", @"0000000150", @"0000000160"];
    icons = @[@"heartbeat", @"temperature", @"humidity", @"motion", @"following"];
    chMinVal = @[@0.0f, @20.0f, @20.0f, @0.0f, @0.0f];
    chMaxVal = @[@250.0f, @50.0f, @100.0f, @2.0f, @100.0f];
    values = [[NSMutableArray alloc] initWithArray:@[@0.0f, @0.0f, @0.0f, @0.0f, @0.0f]];
    
    
    AWSIoTDataManager *iotDataMgr = AWSIoTDataManager.defaultIoTDataManager;
    
    [iotDataMgr subscribeToTopic:@"log/test" QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce messageCallback:^(NSData *payload) {
        NSError *error;
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:payload options:0 error:&error];
        if (jsonDict != nil) {
            NSString *curCh = jsonDict[@"channel"];
            NSString *value = jsonDict[@"value"];
            
            NSLog(@"Get sensor value: %@", value);
            NSNumber *origValue = [Crypto decryptValue:value];
            for (int index = 0; index < channels.count; index++) {
                if ([channels[index] isEqual:curCh]) {
                    values[index] = origValue;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [channels count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MMTableViewCell" forIndexPath:indexPath];
    
    MMTableViewCell *mmCell = (MMTableViewCell*)cell;
    if (mmCell != nil) {
        mmCell.channelName.text = channelNames[indexPath.row];
        mmCell.icon.image = [UIImage imageNamed:icons[indexPath.row]];
        mmCell.value.text = [NSString stringWithFormat:@"%.1f", [values[indexPath.row] floatValue]];
    }
    
    return cell;
}

    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[LineChartTimeViewController alloc] init];
    
    LineChartTimeViewController *timeChartVC = (LineChartTimeViewController*)vc;
    if (timeChartVC != nil) {
        [timeChartVC setChannel:channelNames[indexPath.row]];
        [timeChartVC setChannelNo:channelNo[indexPath.row]];
        [timeChartVC setMinVal:chMinVal[indexPath.row]];
        [timeChartVC setMaxVal:chMaxVal[indexPath.row]];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self performSegueWithIdentifier:@"DDBSeguePushDetailViewController"
    //                          sender:[tableView cellForRowAtIndexPath:indexPath]];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
