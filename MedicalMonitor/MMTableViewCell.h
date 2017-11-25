//
//  MMTableViewCell.h
//  MedicalMonitor
//
//  Created by Weidian on 11/8/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMTableViewCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UIImageView *icon;
    @property (weak, nonatomic) IBOutlet UILabel *channelName;
    @property (weak, nonatomic) IBOutlet UILabel *value;

@end
