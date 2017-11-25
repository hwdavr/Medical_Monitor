/*
 * Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@class DDBTableRow;

@interface DDBDynamoDBManager : NSObject

+ (AWSTask *)describeTable;
+ (AWSTask *)createTable;

@end

@interface DDBTableRow : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *client_id;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *value;


@end
