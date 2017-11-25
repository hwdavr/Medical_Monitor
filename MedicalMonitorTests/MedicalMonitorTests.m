//
//  MedicalMonitorTests.m
//  MedicalMonitorTests
//
//  Created by Weidian on 5/8/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Crypto.h"

@interface MedicalMonitorTests : XCTestCase

@end

@implementation MedicalMonitorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSNumber *number = [Crypto decryptValue:@"8n2S2uIReC/vHSvZrom4Bj"];
    NSLog(@"Decode number is: %@", number);
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
