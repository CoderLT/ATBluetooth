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
    objc_setAssociatedObject(self, @selector(exRSSI), exRSSI, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)exAdvertisementData {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setExAdvertisementData:(NSDictionary *)exAdvertisementData {
    objc_setAssociatedObject(self, @selector(exAdvertisementData), exAdvertisementData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation CBService (Wechat)
- (NSNumber *)supportProbuf {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setSupportProbuf:(NSNumber *)supportProbuf {
    objc_setAssociatedObject(self, @selector(supportProbuf), supportProbuf, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CBCharacteristic *)charateristicRead {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCharateristicRead:(CBCharacteristic *)charateristicRead {
    objc_setAssociatedObject(self, @selector(charateristicRead), charateristicRead, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CBCharacteristic *)charateristicWrite {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCharateristicWrite:(CBCharacteristic *)charateristicWrite {
    objc_setAssociatedObject(self, @selector(charateristicWrite), charateristicWrite, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CBCharacteristic *)charateristicIndicate {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCharateristicIndicate:(CBCharacteristic *)charateristicIndicate {
    objc_setAssociatedObject(self, @selector(charateristicIndicate), charateristicIndicate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (WcBpMessage *)message {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setMessage:(WcBpMessage *)message {
    objc_setAssociatedObject(self, @selector(message), message, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateWechatIfNeed {
    if ([self.UUID.UUIDString isEqualToString:@"FEE7"]) {
        CBCharacteristic *characteriscticWrite, *characteriscticRead, *characteriscticIndicate;
        for (CBCharacteristic *characterisctic in self.characteristics) {
            if ([characterisctic.UUID.UUIDString isEqualToString:@"FEC7"]) {
                if (characterisctic.properties & (CBCharacteristicPropertyWrite|CBCharacteristicPropertyWriteWithoutResponse)) {
                    characteriscticWrite = characterisctic;
                }
            }
            else if ([characterisctic.UUID.UUIDString isEqualToString:@"FEC8"]) {
                if (characterisctic.properties & (CBCharacteristicPropertyIndicate | CBCharacteristicPropertyNotify)) {
                    characteriscticIndicate = characterisctic;
                }
            }
            else if ([characterisctic.UUID.UUIDString isEqualToString:@"FEC9"]) {
                if (characterisctic.properties & (CBCharacteristicPropertyRead)) {
                    characteriscticRead = characterisctic;
                }
            }
        }
        if (characteriscticRead && characteriscticWrite && characteriscticIndicate) {
            self.supportProbuf = @(YES);
            self.charateristicIndicate = characteriscticIndicate;
            self.charateristicWrite = characteriscticWrite;
            self.charateristicRead = characteriscticRead;
            self.message = [[WcBpMessage alloc] init];
        }
    }
}
@end