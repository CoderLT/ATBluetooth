//
//  ATPeripheralController.h
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <BabyBluetooth/BabyBluetooth.h>
#import <SVProgressHUD.h>

@interface ATPeripheralController : UITableViewController

@property (nonatomic, strong) BabyBluetooth *bluetooth;
@property (nonatomic, strong) CBPeripheral *peripheral;

+ (instancetype)vcWithBluetooth:(BabyBluetooth *)bluetooth peripheral:(CBPeripheral *)peripheral;
@end
