//
//  Header.h
//  MedicalMonitor
//
//  Created by Weidian on 25/11/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import <Foundation/Foundation.h>
#import "DataModel.h"
@interface OcDataModel : NSObject {
    DataModel* wrapped;
}

@property DataModel* wrapped2;
- (void)print_message;
// other wrapped methods and properties
@end

#endif /* Header_h */
