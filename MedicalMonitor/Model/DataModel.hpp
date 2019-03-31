//
//  DataModel.hpp
//  MedicalMonitor
//
//  Created by Weidian on 25/11/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#pragma once

#include <stdio.h>
#include "sensor_conf.hpp"
#include "util_list.h"
#include "iot_device.hpp"

class DataModel
{
public:
    const char* message;
public:
    DataModel(sensor_conf &conf);
    ~DataModel();
    void print_message();
private:
    int printf(const char * __restrict format, ...);
private:
    int data;
    sensor_conf& config0;
    sensor_conf  config1;
    util_list<iot_device> mIotDeviceList;
};

