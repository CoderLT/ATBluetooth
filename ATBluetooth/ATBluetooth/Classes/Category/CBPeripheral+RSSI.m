//
//  CBPeripheral+RSSI.m
//  ATBluetooth
//
//  Created by 敖然 on 15/11/19.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "CBPeripheral+RSSI.h"
#import <objc/runtime.h>

@implementation CBPeripheral (RSSI)
- (NSNumber *)exRSSI {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setExRSSI:(NSNumber *)exRSSI {
    objc_setAssociatedObject(self, @selector(exRSSI), exRSSI, OBJC_ASSOCIATION_ASSIGN);
}
@end
