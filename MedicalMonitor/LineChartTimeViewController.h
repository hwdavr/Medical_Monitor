//
//  LineChartTimeViewController.h
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import <UIKit/UIKit.h>
#import "DemoBaseViewController.h"
//#import <Charts/Charts-umbrella.h>

@interface LineChartTimeViewController : DemoBaseViewController

@property (nonatomic) NSString* channel;
@property (nonatomic) NSString* channelNo;
@property (nonatomic) NSNumber* maxVal;
@property (nonatomic) NSNumber* minVal;

@end
