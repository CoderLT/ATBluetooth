//
//  ATBlueoothTool.m
//  ATBluetooth
//
//  Created by 敖然 on 15/12/23.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATBlueoothTool.h"

@implementation ATBlueoothTool

+ (NSString *)properties:(CBCharacteristicProperties)properties separator:(NSString *)separator {
    NSMutableString *desc = [NSMutableString string];
    separator = separator?:@"";
    if (properties & CBCharacteristicPropertyBroadcast) {
        [desc appendFormat:@"%@广播", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyRead) {
        [desc appendFormat:@"%@可读", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [desc appendFormat:@"%@写无回复", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyWrite) {
        [desc appendFormat:@"%@可写", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyNotify) {
        [desc appendFormat:@"%@通知", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyIndicate) {
        [desc appendFormat:@"%@声明", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        [desc appendFormat:@"%@写带签名", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyExtendedProperties) {
        [desc appendFormat:@"%@拓展", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyNotifyEncryptionRequired) {
        [desc appendFormat:@"%@加密通知", desc.length ? separator : @""];
    }
    if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) {
        [desc appendFormat:@"%@加密声明", desc.length ? separator : @""];
    }
    return desc;
}
@end
