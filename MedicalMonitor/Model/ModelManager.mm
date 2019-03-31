//
//  ModelManager.m
//  MedicalMonitor
//
//  Created by Weidian on 25/11/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import "ModelManager.h"
#import "DataModel.hpp"
#import "sensor_conf.hpp"

@interface ModelManager () {
    DataModel* wrapped;
    //sensor_conf sensorConfig;
}
@end


@implementation ModelManager
sensor_conf sensorConfig = sensor_conf::get_instance();

-(void)printMessage
{
    wrapped = new DataModel(sensorConfig);
    wrapped->print_message();
}

@end
