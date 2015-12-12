//
//  CBPeripheral+RSSI.h
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (RSSI)
@property (nonatomic, assign) NSNumber *exRSSI;
@end
