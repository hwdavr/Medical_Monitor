//
//  LineChartTimeViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "LineChartTimeViewController.h"
#import "Charts-Swift.h"
#import "DateValueFormatter.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "DDBDynamoDBManager.h"
#import "SettingViewController.h"
#import "Crypto.h"

@interface LineChartTimeViewController () <ChartViewDelegate> {
NSMutableArray* chartValues;
NSMutableArray* allValues;
NSUInteger curIndex;
}

@property (nonatomic, strong) IBOutlet LineChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;

@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;



@property (nonatomic, readonly) NSLock *lock;
@property (nonatomic, strong) NSDictionary *lastEvaluatedKey;
@property (nonatomic, assign) BOOL doneLoading;

@end

@implementation LineChartTimeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _channel;
    _lock = [NSLock new];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc]
                                   initWithTitle:@"SETTING"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(settingView:)];
    
    [menuItem setImage:[UIImage imageNamed:@"iconMenu"]];
    self.navigationItem.rightBarButtonItem = menuItem;
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleFilled", @"label": @"Toggle Filled"},
                     @{@"key": @"toggleCircles", @"label": @"Toggle Circles"},
                     @{@"key": @"toggleCubic", @"label": @"Toggle Cubic"},
                     @{@"key": @"toggleHorizontalCubic", @"label": @"Toggle Horizontal Cubic"},
                     @{@"key": @"toggleStepped", @"label": @"Toggle Stepped"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];
    
    _chartView.delegate = self;
    _chartView.noDataText = @"Loading Data...";
    _chartView.noDataFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.f];
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.highlightPerDragEnabled = YES;

    _chartView.backgroundColor = UIColor.whiteColor;
    
    _chartView.legend.enabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionTopInside;
    xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    xAxis.labelTextColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:56/255.0 alpha:1.0];
    xAxis.drawAxisLineEnabled = NO;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.granularity = 3600.0;
    xAxis.valueFormatter = [[DateValueFormatter alloc] init];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelPosition = YAxisLabelPositionInsideChart;
    leftAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    leftAxis.labelTextColor = [UIColor colorWithRed:51/255.0 green:181/255.0 blue:229/255.0 alpha:1.0];
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.granularityEnabled = YES;
    leftAxis.axisMinimum = [_minVal floatValue];
    leftAxis.axisMaximum = [_maxVal floatValue];
    leftAxis.yOffset = -9.0;
    leftAxis.labelTextColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:56/255.0 alpha:1.0];
    
    _chartView.rightAxis.enabled = NO;
    
    _chartView.legend.form = ChartLegendFormLine;
    
    chartValues = [[NSMutableArray alloc] init];
    allValues = [[NSMutableArray alloc] init];
    curIndex = 0;
    _doneLoading = FALSE;
    
    [self slidersValueChanged:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
    //[self setDataCount:_sliderX.value range:30.0];
    [self refreshList:0];
}

- (void)setDataCount:(int)count range:(double)range
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval hourSeconds = 50.0;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    NSTimeInterval from = now - (count / 2.0) * hourSeconds;
    NSTimeInterval to = now + (count / 2.0) * hourSeconds;
    
    NSInteger index = 0;
    for (NSTimeInterval x = from; x < to; x += hourSeconds)
    {
        //double y = arc4random_uniform(range) + 50;
        //[values addObject:[[ChartDataEntry alloc] initWithX:x y:[chartValues[index] floatValue]]];
        index++;
    }

    LineChartDataSet *set1 = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = chartValues;
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:chartValues label:@"DataSet 1"];
        set1.axisDependency = AxisDependencyLeft;
        set1.valueTextColor = [UIColor colorWithRed:51/255.0 green:181/255.0 blue:229/255.0 alpha:1.0];
        set1.lineWidth = 1.5;
        set1.drawCirclesEnabled = NO;
        set1.drawValuesEnabled = NO;
        set1.fillAlpha = 0.26;
        set1.fillColor = [UIColor colorWithRed:51/255.0 green:181/255.0 blue:229/255.0 alpha:1.0];
        set1.highlightColor = [UIColor colorWithRed:224/255.0 green:117/255.0 blue:117/255.0 alpha:1.0];
        set1.drawCircleHoleEnabled = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.0]];
        
        _chartView.data = data;
    }
}

    
- (AWSTask *)refreshList:(NSUInteger)startIndex {
    if (startIndex + 100 <= [allValues count]) {
        [chartValues removeAllObjects];
        for (NSInteger i = startIndex + 99; i > startIndex; i--) {
            ChartDataEntry *entry = allValues[i];
            if (entry == nil) continue;
            [chartValues addObject:entry];
        }
        curIndex = startIndex + 100;
        [self setDataCount:[chartValues count] range:100];
    } else if ([self.lock tryLock]) {
        if (self.doneLoading) {
            return nil;
        }
        if (startIndex == 0) {
            self.lastEvaluatedKey = nil;
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        //        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        //        scanExpression.exclusiveStartKey = self.lastEvaluatedKey;
        //        scanExpression.limit = @20;
        //Query using gsi index table
        //What is the top score ever recorded for the game Meteor Blasters?
        AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
        queryExpression.scanIndexForward = @NO;
        queryExpression.exclusiveStartKey = self.lastEvaluatedKey;
        //queryExpression.indexName = @"client_id";
        
        queryExpression.keyConditionExpression = [NSString stringWithFormat:@"client_id = :idval AND #d > :rangeval"];
        
        queryExpression.expressionAttributeValues = @{
                                                      @":idval" : _channelNo,
                                                      @":rangeval" : @"2017-04-29 14:56:000"
                                                      };
        
        queryExpression.expressionAttributeNames = @{@"#d": @"timestamp"};
        queryExpression.limit = @100;
        
        AWSTask *task = [[[dynamoDBObjectMapper query:[DDBTableRow class]
                                           expression:queryExpression]
                          continueWithExecutor:[AWSExecutor mainThreadExecutor] withSuccessBlock:^id(AWSTask *task) {
                              [chartValues removeAllObjects];
                              AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                              for (DDBTableRow *item in paginatedOutput.items) {
                                  NSNumber* origValue = [Crypto decryptValue:item.value];
                                  ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:[self timeFromString:item.timestamp] y:[origValue floatValue]];
                                  [allValues addObject:entry];
                              }
                              for (DDBTableRow *item in [[paginatedOutput.items reverseObjectEnumerator] allObjects]) {
                                  NSNumber* origValue = [Crypto decryptValue:item.value];
                                  //NSLog(@"Date Time: %@, %f, %f", item.timestamp, [self timeFromString:item.timestamp], [origValue floatValue]);
                                  ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:[self timeFromString:item.timestamp] y:[origValue floatValue]];
                                  [chartValues addObject:entry];
                              }
                              curIndex = [allValues count];
                              
                              [self setDataCount:[chartValues count] range:100];
                              
                              self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey;
                              if (!paginatedOutput.lastEvaluatedKey) {
                                  self.doneLoading = YES;
                                  [_btnPrevious setEnabled:NO];
                              }
                              
                              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                              
                              return nil;
                          }] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
                              if (task.error) {
                                  NSLog(@"Error: [%@]", task.error);
                              }
                              
                              [self.lock unlock];
                              
                              return nil;
                          }];
        return task;
    } else {
        [_btnPrevious setEnabled:NO];
    }
    return nil;
}

- (NSTimeInterval)timeFromString:(NSString*)timestamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:9.0]];
    NSDate *currentDate = [dateFormatter dateFromString:timestamp];
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    return interval;
}

- (NSString*)stringFromTimeInterval:(NSTimeInterval)interval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    // Divided by 1000 (i.e. removed three trailing zeros) ^^^^^^^^
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"toggleFilled"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawFilledEnabled = !set.isDrawFilledEnabled;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }
    
    if ([key isEqualToString:@"toggleCircles"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawCirclesEnabled = !set.isDrawCirclesEnabled;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }
    
    if ([key isEqualToString:@"toggleCubic"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.mode = set.mode == LineChartModeCubicBezier ? LineChartModeLinear : LineChartModeCubicBezier;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }

    if ([key isEqualToString:@"toggleStepped"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawSteppedEnabled = !set.isDrawSteppedEnabled;
        }

        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleHorizontalCubic"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.mode = set.mode == LineChartModeCubicBezier ? LineChartModeHorizontalBezier : LineChartModeCubicBezier;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }
    
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    _sliderTextX.text = [@((int)_sliderX.value) stringValue];
    
    [self updateChartData];
}

- (IBAction)loadNextData:(id)sender {
    // Enable the increase button
    [_btnPrevious setEnabled:YES];
    
    NSUInteger startIndex = curIndex;
    if (startIndex >= 200) {
        startIndex -= 200;
    } else {
        startIndex = 0;
        [_btnNext setEnabled:NO];
    }
    [self refreshList:startIndex];
}

- (IBAction)loadPreviousData:(id)sender {
    [_btnNext setEnabled:YES];
    NSUInteger startIndex = curIndex;
    [self refreshList:startIndex];
}

- (IBAction)resetData:(id)sender {
    [self refreshList:0];
}

- (IBAction)settingView:(id)sender {
    SettingViewController *vc = [[SettingViewController alloc] initWithNibName: @"SettingViewController" bundle: nil];
    if (vc != nil) {
        [vc setChannelNo:_channelNo];
        [vc setMaxVal:_maxVal];
        [vc setMinVal:_minVal];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    // Fri, 28 Jun 2013 11:26:29 GMT
    _lblInfo.text = [NSString stringWithFormat:@"X: %@  Y:%.2f", [self stringFromTimeInterval:entry.x], entry.y];
    NSLog(@"chartValueSelected, %0.2f", entry.y);
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    _lblInfo.text = @"";
    NSLog(@"chartValueNothingSelected");
}

@end
