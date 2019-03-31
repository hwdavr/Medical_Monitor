//
//  iot_device.hpp
//  MedicalMonitor
//
//  Created by Weidian on 2/12/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#ifndef iot_device_hpp
#define iot_device_hpp

#include <stdio.h>

class iot_device
{
public:
    iot_device();
    ~iot_device();
    int index;
protected:
    // Meta description
    const char *mMInDesc;
    const char *mMaxDesc;
private:
    // Big static shared buffer for all derived class. Not thread-safe!
    // Derived class may use this buffer to put the formated data, or can use
    // its own internal buffer.
    static const int mStaticSharedBufferSize = 512;
    static char mStaticSharedBuffer[mStaticSharedBufferSize];
};

#endif /* iot_device_hpp */
