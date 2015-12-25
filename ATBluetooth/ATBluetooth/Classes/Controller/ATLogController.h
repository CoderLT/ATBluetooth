//
//  ATLogController.h
//  ATBluetooth
//
//  Created by 敖然 on 15/12/23.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATBTData.h"

@interface ATLogController : UIViewController

+ (instancetype)vcWithLogs:(NSArray<ATBTData *> *)logs;
@end
