//
//  ATGATTTool.h
//  ATBluetooth
//
//  Created by 敖然 on 15/12/25.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ATGATTTool : NSObject

+ (instancetype)shareInstance;

- (NSString *)serviceDesc:(CBService *)service;
- (NSString *)serviceDescWithUUID:(CBUUID *)uuid;

- (NSString *)characteristicDesc:(CBCharacteristic *)characteristic;
- (NSString *)characteristicDescWithUUID:(CBUUID *)uuid;
@end
