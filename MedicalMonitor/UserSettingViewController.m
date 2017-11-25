//
//  UserSettingViewController.m
//  MedicalMonitor
//
//  Created by Weidian on 12/11/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import "UserSettingViewController.h"
#import "Constants.h"

@interface UserSettingViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfUserId;
@property (weak, nonatomic) IBOutlet UITextField *tfDeviceId;
@property (weak, nonatomic) IBOutlet UITextField *tfUserName;
@property (weak, nonatomic) IBOutlet UITextField *tfMobileNo;

//declare a property to store your current responder
@property (nonatomic, assign) id currentResponder;

@end

@implementation UserSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* userId = [userDefaults objectForKey:KEY_USER_ID];
    if (userId == nil) {
        userId = @"00000001";
        [userDefaults setObject:userId forKey:KEY_USER_ID];
    }
    [_tfUserId setText:userId];
    _tfUserId.delegate = self;
    NSString* deviceId = [userDefaults objectForKey:KEY_DEVICE_ID];
    if (deviceId == nil) {
        deviceId = @"AABBCCDD";
        [userDefaults setObject:deviceId forKey:KEY_DEVICE_ID];
    }
    [_tfDeviceId setText:deviceId];
    _tfDeviceId.delegate = self;
    _tfUserName.delegate = self;
    _tfMobileNo.delegate = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setUserId:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString* userId = [textField text];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userId forKey:KEY_USER_ID];
}

- (IBAction)setDeviceId:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString* deviceId = [textField text];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:deviceId forKey:KEY_DEVICE_ID];
}

//Implement resignOnTap:
- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view resignFirstResponder];
    return YES;
}


#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
//    else if (self.view.frame.origin.y < 0)
//    {
//        [self setViewMovedUp:NO];
//    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    _currentResponder = sender;
    if ([sender isEqual:_tfDeviceId])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view

    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;

    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardWillShow)
                                             name:UIKeyboardWillShowNotification
                                           object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardWillHide)
                                             name:UIKeyboardWillHideNotification
                                           object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                             name:UIKeyboardWillShowNotification
                                           object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                             name:UIKeyboardWillHideNotification
                                           object:nil];
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
