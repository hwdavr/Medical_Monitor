//
//  DataModel.cpp
//  MedicalMonitor
//
//  Created by Weidian on 25/11/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#include "DataModel.hpp"
#import <Foundation/Foundation.h>


DataModel::DataModel(sensor_conf &conf) : config0(conf)
{
    message = "Weidian";
    data = 100;
    iot_device *temp0 = new iot_device;
    temp0->index = 0;
    iot_device *temp1 = new iot_device;
    temp1->index = 1;
    iot_device *temp2 = new iot_device;
    temp2->index = 2;
    mIotDeviceList.push_back(temp0);
    mIotDeviceList.push_back(temp1);
    mIotDeviceList.push_back(temp2);
}

void deletor(iot_device *device)
{
    delete device;
}

DataModel::~DataModel()
{
    mIotDeviceList.clear(&deletor);
}

void DataModel::print_message()
{
    fprintf(stdout, "test: %s\n", message);
    printf("Sensor configuration: %d", config0.get_parameter_at(sensor_conf::temperature));
    printf("Sensor configuration: %d", config0.get_parameter_at(sensor_conf::motion));
    
    for (util_list<iot_device>::iterator i = mIotDeviceList.begin();
         i != mIotDeviceList.end(); i++) {
        printf("Itenery the item: %d", (*i)->index);
    }
}

int DataModel::printf(const char * __restrict format, ...)
{
    va_list args;
    va_start(args,format);
    NSLogv([NSString stringWithUTF8String:format], args) ;
    va_end(args);
    return 1;
}
