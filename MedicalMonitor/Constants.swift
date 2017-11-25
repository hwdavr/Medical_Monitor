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

import Foundation
import AWSCore

//WARNING: To run this sample correctly, you must set the following constants.
let AwsRegion = AWSRegionType.APNortheast1 // e.g. AWSRegionType.USEast1
let CognitoIdentityPoolId = "ap-northeast-1:9679dfde-7663-4147-91e9-a59a181e4dfb"
let CertificateSigningRequestCommonName = "RemotePatientMonitorIOS"
let CertificateSigningRequestCountryName = "Singapore"
let CertificateSigningRequestOrganizationName = "115883031008"
let CertificateSigningRequestOrganizationalUnitName = "RND"
let PolicyName = "Test-Policy"
//This is the endpoint in your AWS IoT console. eg: https://xxxxxxxxxx.iot.<region>.amazonaws.com
let IOT_ENDPOINT = "https://a14gfov13yl748.iot.ap-northeast-1.amazonaws.com"
