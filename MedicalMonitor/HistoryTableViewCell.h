//
//  HistoryTableViewCell.h
//  MedicalMonitor
//
//  Created by Weidian on 9/9/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *message;

@end
