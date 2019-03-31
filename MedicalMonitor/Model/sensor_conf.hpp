//
//  sensor_conf.hpp
//  MedicalMonitor
//
//  Created by Weidian on 25/11/17.
//  Copyright © 2017 talengineer. All rights reserved.
//
#pragma once

#include <stdio.h>

class sensor_conf
{
public:
    enum index {
        pulse = 0,
        temperature,
        humidity,
        motion,
        all,
    };
public:
    sensor_conf();
    const static sensor_conf& get_instance();
    const int get_parameter_at(index pId) const;
private:
    
private:
    int mConfList[all];
};
