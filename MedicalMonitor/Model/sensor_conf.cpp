//
//  sensor_conf.cpp
//  MedicalMonitor
//
//  Created by Weidian on 25/11/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#include "sensor_conf.hpp"

sensor_conf::sensor_conf() {
    mConfList[pulse] = 23;
    mConfList[temperature] = 322;
    mConfList[humidity] = 90;
}

const sensor_conf& sensor_conf::get_instance() {
    static sensor_conf config;
    return config;
}

// const function() const, cannot modify the variable in the function
const int sensor_conf::get_parameter_at(index pId) const {
    return mConfList[pId];
}
