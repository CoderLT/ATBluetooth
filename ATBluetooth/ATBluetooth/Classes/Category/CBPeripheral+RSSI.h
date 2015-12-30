//
//  CBPeripheral+RSSI.h
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "WcBpMessage.h"

@interface CBPeripheral (RSSI)
@property (nonatomic, strong) NSNumber *exRSSI;
@property (nonatomic, strong) NSDictionary *exAdvertisementData;
@end

@interface CBService (Wechat)
@property (nonatomic, assign) NSNumber *supportProbuf;
@property (nonatomic, strong) CBCharacteristic *charateristicWrite;
@property (nonatomic, strong) CBCharacteristic *charateristicRead;
@property (nonatomic, strong) CBCharacteristic *charateristicIndicate;
@property (nonatomic, strong) WcBpMessage *message;

- (void)updateWechatIfNeed;
@end