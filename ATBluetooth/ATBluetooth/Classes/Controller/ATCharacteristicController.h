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

@interface ATCharacteristicController : UIViewController

@property (nonatomic, strong) BabyBluetooth *bluetooth;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

+ (instancetype)vcWithBluetooth:(BabyBluetooth *)bluetooth
                     peripheral:(CBPeripheral *)peripheral
                 characteristic:(CBCharacteristic *)characteristic;
@end
