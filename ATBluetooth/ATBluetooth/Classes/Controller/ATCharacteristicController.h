//
//  ATCharacteristicController.h
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <BabyBluetooth/BabyBluetooth.h>
#import <SVProgressHUD.h>
#import "ATBTData.h"

@interface ATCharacteristicController : UITableViewController

@property (nonatomic, strong) BabyBluetooth *bluetooth;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) NSMutableArray<ATBTData *> *logs;

+ (instancetype)vcWithBluetooth:(BabyBluetooth *)bluetooth
                     peripheral:(CBPeripheral *)peripheral
                 characteristic:(CBCharacteristic *)characteristic
                           logs:(NSMutableArray<ATBTData *> *)logs;
@end
